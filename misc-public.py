def get_hash(filepath, hash_type="sha512"):
    """Function to return the digest hash of a file based on filename and algorithm"""
    import hashlib
    HASH_BLOCK_SIZE = 1024 * 1024
    digest = hashlib.new(hash_type)
    with open(filepath, "rb") as fobj:
        while True:
            chunk = fobj.read(HASH_BLOCK_SIZE)
            if not chunk:
                break
            digest.update(chunk)
    return digest.hexdigest()


def get_file_size(filepath):
    import os
    if not os.path.isfile(filepath):
        raise ValueError(f"The path '{filepath}' is not a valid file.")
    return os.path.getsize(filepath)


def schedule(tasks):
    print('#!/bin/bash\n')
    for t in tasks:
        print(f'# rerun {t}')
        print(f"echo \"running {t}\"")
        print(f"taskcluster api queue scheduleTask \"{t}\"\n")


def load_taskgraph(path='./artifacts/task-graph.json'):
    import json
    f = open(path)
    data = f.read()
    f.close()
    taskgraph = json.loads(data)
    return taskgraph


def load_firefox_ci_task_graph(task_id, task_run=0):
    import requests
    url = f"https://firefoxci.taskcluster-artifacts.net/{task_id}/{task_run}/public/task-graph.json"
    response = requests.get(url)
    task_graph = response.json()
    url = f"https://firefoxci.taskcluster-artifacts.net/{task_id}/{task_run}/public/label-to-taskid.json"
    response = requests.get(url)
    label_to_task_id = response.json()
    return task_graph, label_to_task_id


def open_task(task_id):
    import webbrowser
    webbrowser.open(f"https://firefox-ci-tc.services.mozilla.com/tasks/{task_id}", new=2)


def pick(picks, d):
    from toolz import keyfilter
    return keyfilter(lambda k: k in picks, d)


def omit(omissions, d):
    from toolz import keyfilter
    return keyfilter(lambda k: k not in omissions, d)


def dict_from_json(json_string):
    import json
    return json.loads(json_string)


def data_from_filename(filename):
    with open(filename) as f:
        return f.read()


def pp(obj):
    from pprint import pprint as pp
    pp(obj)
