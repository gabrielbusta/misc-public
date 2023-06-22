def load_taskgraph(filename):
    import json
    f = open('./artifacts/task-graph.json')
    data = f.read()
    f.close()
    taskgraph = json.loads(data)
    f = open('./artifacts/label-to-taskid.json')
    data = f.read()
    f.close()
    ID = json.loads(data)
    return taskgraph, ID


def pick(picklist, d):
    from toolz import keyfilter
    return keyfilter(lambda k: k in picklist, d)
