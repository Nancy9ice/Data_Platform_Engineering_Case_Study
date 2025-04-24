from airflow.models import DagBag

def test_dag_has_start_date():
    """
    Test that all DAGs have start_date either directly in the DAG or in default_args.
    """
    dag_without_start_date = []
    
    for dag_id, dag in dag_bag.dags.items():
        # Check both the direct attribute and default_args
        if not dag.start_date and not (dag.default_args and 'start_date' in dag.default_args):
            dag_without_start_date.append(dag_id)
    
    # list the dags without start date
    assert not dag_without_start_date, (
        "These DAGs have no start_date:\n"
        + "\n".join(no_start_date)
    )