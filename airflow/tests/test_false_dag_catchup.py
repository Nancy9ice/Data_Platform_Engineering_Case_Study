from airflow.models import DagBag


def test_false_dag_catchup():
    """
    Test that the DAG has catchup set to False
    """
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)

    # loop through the dags to get all dags
    for dag_id, dag in dag_bag.dags.items():
        assert (
            dag.catchup is False
        ), f"DAG {dag_id} has catchup=True (expected False)"
