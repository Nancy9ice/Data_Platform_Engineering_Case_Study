from airflow.models import DagBag


def test_dag_import_error():
    """
    Checks that the Airflow dags have no import errors
    """
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)

    # check for dag import errors
    assert not dag_bag.import_errors, \
        f"DAG import errors detected: {dag_bag.import_errors}"
