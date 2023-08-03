import json
import logging
import sys
import urllib
from dataclasses import dataclass

import certifi
import mohawk
import requests
from redo import retry

logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)


def get_request_headers(api_root):
    """Create headers needed for shipit requests"""
    # shipit API forces https:// by redirecting to the HTTPS port if the
    # request uses http:// or the traffic comes from the proxy, which sets the
    # "X-Forwarded-Proto" header to "https".
    # Shipitscript workers work in the same cluster with shipit, and they use
    # http:// and local addresses in order to bypass the load balancer.
    # The X-Forwarded-Proto header affects flask_talisman and prevents it from
    # upgrading the connection to https://.
    # The X-Forwarded-Port header explicitly specifies the used port to prevent
    # the API using the nginx proxy port to construct the mohawk payload.

    parsed_url = urllib.parse.urlsplit(api_root)
    if parsed_url.port:
        port = parsed_url.port
    else:
        if parsed_url.scheme == "https":
            port = 443
        else:
            port = 80
    headers = {"X-Forwarded-Proto": "https", "X-Forwarded-Port": str(port)}
    return headers


class Release_V2(object):
    """A class that knows how to make requests to a Ship It v2 server,
    including generating hawk headers.
    """

    def __init__(
        self,
        taskcluster_client_id,
        taskcluster_access_token,
        api_root,
        ca_certs=certifi.where(),
        timeout=60,
        retry_attempts=5,
    ):
        self.taskcluster_client_id = taskcluster_client_id
        self.taskcluster_access_token = taskcluster_access_token
        self.api_root = api_root.rstrip("/")
        self.verify = ca_certs
        self.timeout = timeout
        self.retries = retry_attempts
        self.session = requests.session()

    @staticmethod
    def _get_taskcluster_headers(
        request_url, method, content, taskcluster_client_id, taskcluster_access_token
    ):
        hawk = mohawk.Sender(
            {
                "id": taskcluster_client_id,
                "key": taskcluster_access_token,
                "algorithm": "sha256",
            },
            request_url,
            method,
            content,
            content_type="application/json",
        )
        return {
            "Authorization": hawk.request_header,
            "Content-Type": "application/json",
        }

    def _request(self, api_endpoint, data=None, method="GET", headers={}):
        url = "{}{}".format(self.api_root, api_endpoint)
        headers = headers.copy()
        if method.upper() not in ("GET", "HEAD"):
            headers.update(
                self._get_taskcluster_headers(
                    url,
                    method,
                    data,
                    self.taskcluster_client_id,
                    self.taskcluster_access_token,
                )
            )
        try:

            def _req():
                req = self.session.request(
                    method=method,
                    url=url,
                    data=data,
                    timeout=self.timeout,
                    verify=self.verify,
                    headers=headers,
                )
                req.raise_for_status()
                return req

            return retry(
                _req,
                sleeptime=5,
                max_sleeptime=15,
                retry_exceptions=(requests.HTTPError, requests.ConnectionError),
                attempts=self.retries,
            )
        except requests.HTTPError as err:
            log.error(
                "Caught HTTPError: %d %s",
                err.response.status_code,
                err.response.content,
                exc_info=True,
            )
            raise

    def getRelease(self, name, headers={}):
        resp = None
        try:
            resp = self._request(
                api_endpoint="/releases/{}".format(name), headers=headers
            )
            return json.loads(resp.content)
        except Exception:
            log.error("Caught error while getting release", exc_info=True)
            if resp:
                log.error(resp.content)
                log.error(f"Response code: {resp.status_code}")
            raise

    def get_releases(self, product, branch, status, version="", headers={}):
        """Method to map over the GET /releases List releases API in Ship-it"""
        resp = None
        params = {"product": product, "branch": branch, "status": status}
        if version:
            params["version"] = version

        try:
            resp = self._request(
                api_endpoint=f"/releases?{urllib.parse.urlencode(params)}",
                headers=headers,
            )
            return resp.json()
        except Exception:
            log.error("Caught error while getting releases", exc_info=True)
            if resp:
                log.error(resp.content)
                log.error(f"Response code: {resp.status_code}")
            raise

    def update_status(self, name, status, headers={}):
        """Update release status"""
        data = json.dumps({"status": status})
        resp = self._request(
            api_endpoint="/releases/{}".format(name),
            method="PATCH",
            data=data,
            headers=headers,
        ).content
        return resp

    def get_disabled_products(self, headers={}):
        """Method to map over the GET /disabled-products/ API in Ship-it

        Returns which products are disabled for which branches
        {
          "devedition": [
            "releases/mozilla-beta",
            "projects/maple"
          ],
          "firefox": [
            "projects/maple",
            "try"
          ]
        }
        """
        resp = None
        try:
            resp = self._request(api_endpoint="/disabled-products", headers=headers)

            return resp.json()
        except Exception:
            log.error("Caught error while getting disabled-products", exc_info=True)
            if resp:
                log.error(resp.content)
                log.error(f"Response code: {resp.status_code}")
            raise

    def create_new_release(
        self, product, product_key, branch, version, build_number, revision, headers={}
    ):
        """Method to map over the POST /releases/ API in Ship-it"""
        resp = None
        params = {
            "product": product,
            "branch": branch,
            "version": version,
            "build_number": build_number,
            "revision": revision,
            "partial_updates": "auto",
        }

        # some products such as Fennec take an additional argument to differentiate
        # between the flavors
        if product_key:
            params.update({"product_key": product_key})
        # guard the partials parameter to non-Fennec to prevent 400 BAD REQUEST
        if product == "fennec":
            del params["partial_updates"]
        data = json.dumps(params)

        try:
            resp = self._request(
                api_endpoint="/releases", method="POST", data=data, headers=headers
            )
            return resp.json()
        except Exception:
            log.error("Caught error while creating the release", exc_info=True)
            if resp:
                log.error(resp.content)
                log.error(f"Response code: {resp.status_code}")
            raise

    def trigger_release_phase(self, release_name, phase, headers={}):
        """Method to map over the PUT /releases/{name}/{phase} API in Ship-it

        Parameters:
            * release_name
            * phase
        """
        resp = None
        try:
            resp = self._request(
                api_endpoint=f"/releases/{release_name}/{phase}",
                method="PUT",
                data=None,
                headers=headers,
            )
        except Exception:
            log.error(
                f"Caught error while triggering {phase} for {release_name}",
                exc_info=True,
            )
            if resp:
                log.error(resp.content)
                log.error(f"Response code: {resp.status_code}")
            raise


def get_auth_primitives_v2(ship_it_instance_config):
    """Function to grab the primitives needed for shipitapi objects auth"""
    taskcluster_client_id = ship_it_instance_config["taskcluster_client_id"]
    taskcluster_access_token = ship_it_instance_config["taskcluster_access_token"]
    api_root = ship_it_instance_config["api_root_v2"]
    timeout_in_seconds = int(ship_it_instance_config.get("timeout_in_seconds", 60))

    return (
        taskcluster_client_id,
        taskcluster_access_token,
        api_root,
        timeout_in_seconds,
    )


def get_shipit_api_instance(shipit_config):
    (
        tc_client_id,
        tc_access_token,
        api_root,
        timeout_in_seconds,
    ) = get_auth_primitives_v2(shipit_config)

    release_api = Release_V2(
        taskcluster_client_id=tc_client_id,
        taskcluster_access_token=tc_access_token,
        api_root=api_root,
        timeout=timeout_in_seconds,
    )
    headers = get_request_headers(api_root)

    return release_api, headers


@dataclass
class Context:
    task: dict
    ship_it_instance_config: dict


def check_release_has_values_v2(release_api, release_name, headers, **kwargs):
    """Function to make an API call to Ship-it v2 to grab release information
    and validate that fields that had just been updated are correctly reflected
    in the API returns"""
    release_info = release_api.getRelease(release_name, headers=headers)
    log.info("Full release details: {}".format(release_info))

    for key, value in kwargs.items():
        # special case for comparing times
        if not release_info.get(key) or release_info[key] != value:
            err_msg = "`{}`->`{}` don't exist or correspond.".format(key, value)
            raise ScriptWorkerTaskException(err_msg)

    log.info("All release fields have been correctly updated in Ship-it!")


class Actions:
    def mark_as_shipped_v2(shipit_config, release_name):
        """Function to make a simple call to Ship-it API v2 to change a release
        status to 'shipped'
        """
        release_api, headers = get_shipit_api_instance(shipit_config)

        log.info("Marking the release as shipped...")
        release_api.update_status(release_name, status="shipped", headers=headers)
        check_release_has_values_v2(
            release_api, release_name, headers, status="shipped"
        )


ship_actions = Actions


def mark_as_shipped_action(context):
    """Action to perform is to tell Ship-it API that a release can be marked
    as shipped"""
    release_name = context.task["payload"]["release_name"]

    log.info("Marking the release as shipped ...")
    ship_actions.mark_as_shipped_v2(context.ship_it_instance_config, release_name)


def main(args):
    release_name = args[0]
    client_id = args[1]
    access_token = args[2]
    task = {
        "payload": {"release_name": release_name},
    }
    ship_it_instance_config = {
        "api_root_v2": "https://shipit-api.mozilla-releng.net",
        "timeout_in_seconds": 60,
        "taskcluster_client_id": client_id,
        "taskcluster_access_token": access_token,
    }
    context = Context(task=task, ship_it_instance_config=ship_it_instance_config)
    log.info(context)
    mark_as_shipped_action(context)


__name__ == "__main__" and main(sys.argv[1:])
