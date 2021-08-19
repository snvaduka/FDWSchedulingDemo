from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta


args = {
    'start_date': datetime.utcnow(),
    'owner': 'airflow',
}

dag = DAG(
    dag_id='sai_example_dag_conf',
    default_args=args,
    schedule_interval=None,
)

# You can also access the DagRun object in templates
bash_task = BashOperator(
    task_id="bash_task",
    bash_command='/bin/sh /root/airflow/scripts/CreateDag.sh {{ dag_run.conf["github_url"]}} {{ dag_run.conf["manifest"]}}',
    dag=dag,
)