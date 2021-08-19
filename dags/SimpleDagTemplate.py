from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python_operator import PythonOperator
from datetime import datetime, timedelta


args = {
    'start_date': datetime.utcnow(),
    'owner': 'airflow',
}

dag = DAG(
    dag_id='simple_hdbsql_dag_template',
    default_args=args,
    schedule_interval=None,
)

# You can also access the DagRun object in templates
hdbsql_task = BashOperator(
    #Pass your task name
    task_id="Create_Table_Task", 
    #Pass your command
    bash_command=' /usr/sap/hdbclient/hdbsql -n 9f85d8e4-ea13-43bd-93f0-1fbdb14c3bd0.hana.prod-eu10.hanacloud.ondemand.com:443 -u AIRFLOW_SCHEDULER -p Hanadb@123 start task 9265AF07FD7F474F9F4374D564865534.TASK_FDW_CURRENCY_ADJ_F', 
    dag=dag,
)