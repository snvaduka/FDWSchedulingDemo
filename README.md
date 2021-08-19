# AirflowTemplate
The Following are the steps required to perform orchestration of dag using airflow webui

1. Create your repository using the template [https://github.com/snvaduka/AirflowTemplate.git] 
2. After forking the github, you will find the below directory structure
    * [Project]
        * base  <--- Framework code just ignore 
        * dags
            * SimpleDagTemplate.py
            * MediumDagTemplate.py
            * ComplexDagTemplate.py   
        * conf
            * Dependency.conf
            * Dependency.properties
        * scripts
            * UpdateDag.sh
            * CreateDag.sh
            * Template.sh <---- Sample Template as reference
        * requirements
            * Template_requirements.txt <---- Dag dependency requirements   
        * Template.amt <----- Manifest file ***
        
# Follow the below process to create or update a dag
## Create Dag
1. Copy any dag python file under dags based on the requirement, modify the changes in the python file.
2. Add a unique name for dag_id as **<PROJECT_NAME>_<TASK_DETAIL>** in the python file
3. Along with add the respective dependency files in the project
4. Copy the Template.amt and rename to **<YOUR_PROJECT>_<JIRAID_TASKDETAIL>.amt** as per your requirement
5. Below are the details need to fill in the above created manifest file
[SampleTemplate.amt.xlsx](https://github.com/snvaduka/AirflowTemplate/files/6998295/SampleTemplate.amt.xlsx)

<table>
<thead>
<tr>
<th>Key</th>
<th>Value</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>dagfileName</td>
<td>dags/YourDag.py</td>
<td>Location of the dag definition file</td>
</tr>
<tr>
<td>requirements_file</td>
<td>requirements/your_requirements.txt</td>
<td>[NA/requirements/project1_requirements.txt] 
# Pass NA if not applicable
This will be deployed during deployment</td>
</tr>
<tr>
<td>dependencies</td>
<td>scripts/YourShellScript.sh,conf/YourConfig.conf</td>
<td>Specify the dependencies of the dags</td>
</tr>
</tbody>
</table>  


#### Creating New Dag in Airflow ####
1. Login to Airflow URL: http://10.185.38.49:8080/home using the credentials
2. Search for the Dag **mck_fw_create_dag**
![MCK_FW_Create_Dag](https://user-images.githubusercontent.com/88087256/129687718-8dea1cfa-b9e9-45df-8e76-b087b43ae0a7.jpg)
3. Run the Dag with Config
![MCK_FW_Create_Dag_With_Config](https://user-images.githubusercontent.com/88087256/129687938-e4ab451a-1bf5-4f12-8807-29bd1429411e.jpg)
4. In the config mention below input parameters and click on Trigger 
   ```
   { 
      "github_url": "*** Your Github Location ***", 
      "manifest": " *** Your Manifest Information ***" 
    }
   ```
   Sample Reference attachement: [CreateOrUpdateDag.txt](https://github.com/snvaduka/AirflowTemplate/files/6998132/CreateOrUpdateDag.txt)
   
   ![MCK_FW_Create_Dag_Input_config](https://user-images.githubusercontent.com/88087256/129689089-cbb7f33d-4098-440f-8c6f-495be4cc73d7.jpg)

5. The Airflow Dag will appear in the WebUI Console after 5 minutes
## Update Dag
1. Please follow the same steps as [Create Dag](#create-dag), except instead of mck_fw_create_dag please use mck_fw_update_dag
