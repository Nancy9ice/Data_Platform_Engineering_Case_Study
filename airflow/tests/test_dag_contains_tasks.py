from airflow.models import DagBag

def test_dags_contains_tasks():
    """
    Test that each dag contains at least one task
    """
    
    # load the dags
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)
    
    # create empty list for empty dags
    empty_dags = []

    # loop through the dag_bag
    for dag_id, dag in dag_bag.dags.items():
        # get dags with no tasks
        if not dag.tasks:
            empty_dags.append(dag_id)
    
    # assert after getting all empty dags
    assert not empty_dags, f"These DAGs have no tasks: {empty_dags}"