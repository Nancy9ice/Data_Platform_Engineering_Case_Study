from airflow.models import DagBag


def test_dag_has_start_date():
    """
    Test that all DAGs have start_date either
    directly in the DAG or in default_args.
    """
    dag_bag = DagBag(dag_folder="dag/", include_examples=False)

    dag_without_start_date = []

    for dag_id, dag in dag_bag.dags.items():
        # Check for start date in both the direct attribute and default_args
        start_date = dag.start_date or (dag.default_args or {}).get(
            "start_date"
        )
        if not start_date:
            dag_without_start_date.append(dag_id)

    # list the dags without start date
    assert (
        not dag_without_start_date
    ), "These DAGs have no start_date:\n" + "\n".join(dag_without_start_date)
