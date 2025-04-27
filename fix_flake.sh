isort ./airflow
black ./airflow --line-length 79
autopep8 -r ./airflow --in-place --recursive --max-line-length 79 --aggressive --aggressive
