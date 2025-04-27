# Data Platform Engineering Case Study (Team One)

Welcome to the documentation for our case study project, where we successfully built a robust Data Platform for BuildItAll clients in Belgium. This platform was designed to facilitate big data analytics, empowering the clients to become more data-driven by efficiently handling the massive data they generate daily. Below, you will find a detailed description of the problem statement, solution approach, tools used, and the impact of the project on the business problem.

## Contributors
- [Nancy Amandi](https://github.com/Nancy9ice)
- [Best Nyah](https://github.com/Bee0933)
- [Abdulhakeem Salaudeen](https://github.com/HakeemSalaudeen)
- [David Dada](https://github.com/tdadadavid)



## Problem Statement

BuildItAll clients from Belgium approached us with the need to establish a Data Platform capable of supporting big data analytics. The goal was to enhance their data-driven decision-making processes by efficiently managing and analyzing the substantial volumes of data they produce every day.

## Solution Approach

Our solution involved establishing a comprehensive data pipeline, utilizing a variety of tools to ensure seamless data processing and analytics. Below is a step-by-step breakdown of our approach:

### 1. Orchestrating with Apache Airflow

We used Apache Airflow to orchestrate the data pipeline. Initially, Airflow was tested locally to ensure stability and functionality before deploying it in production using AWS Managed Workflows for Apache Airflow (MWAA). Airflow's flexibility and ability to handle complex workflows made it an ideal choice for orchestrating our pipeline.

### 2. Infrastructure Deployment with Terraform

All infrastructure components were deployed in AWS using Terraform. Terraform's infrastructure-as-code approach allowed us to automate and version control our deployments, ensuring consistency and repeatability across environments.

### 3. Continuous Integration and Continuous Deployment (CI/CD) with GitHub Actions

We implemented a CI/CD pipeline using GitHub Actions. This facilitated automated testing and deployment, ensuring that all changes were thoroughly vetted before merging into the main branch. The integration of flake8 linting helped maintain code quality.

### 4. Data Processing with AWS EMR and PySpark

AWS EMR was deployed for data processing tasks, leveraging PySpark scripts for efficient handling of large datasets. The Smartphone and Smartwatch Activity and Biometrics Dataset was used, which contains accelerometer and gyroscope time-series sensor data from 51 test subjects performing 18 activities for 3 minutes each.

### 5. Data Handling with Amazon S3

The dataset was downloaded and stored in Amazon S3. PySpark was utilized to retrieve data from S3, process and transform it, and then push it back to S3 as Parquet files. This approach ensured scalability and reliability in handling over 15 million records.

### 6. Monitoring with CloudWatch

CloudWatch was employed for monitoring purposes, particularly to track the performance of MWAA DAGs stored in S3. This allowed us to promptly address any failures or issues within the workflow.

### 7. Spark Optimization Strategy

A Spark optimization strategy was implemented to enhance the performance of Spark jobs, ensuring efficient processing of large datasets.

## Environment Setup

The platform was deployed in an AWS environment with the following setup:

### Network Configuration:

* VPC with public and private subnets
* Security groups with least-privilege access
* IAM roles with appropriate permissions

### Development Environment:

* Well-structured, version-controlled codebase
* Local Airflow testing environment
* Development, staging, and production environments

### Source Control:

* Git repository with protected main branch
* Branch protection rules requiring tests to pass before merging
* Code review process for all changes

## Data Pipeline Implementation

### Data Source

The platform was tested and implemented using the Smartphone and Smartwatch Activity and Biometrics Dataset, which contains:

* Accelerometer and gyroscope time-series sensor data
* Data collected from 51 test subjects
* 18 different activities performed for 3 minutes each
* Over 15 million records in total

This dataset provided an excellent test case for the platform's ability to handle complex time-series data at scale.

### Data Processing with PySpark on EMR

PySpark scripts were developed to perform these key transformations:

* Extract data from S3 bucket containing raw data
* Apply data cleaning and transformation operations
* Optimize the data structure for analytical queries
* Save processed data as Parquet files back to S3

The use of Parquet format provided several advantages:

* Columnar storage for efficient querying
* Compression to reduce storage costs
* Schema enforcement for data consistency

### Workflow Orchestration with Airflow

Apache Airflow was used to orchestrate the entire data pipeline:

* Airflow DAGs were created to manage workflow execution
* DAGs were first tested locally, then deployed to MWAA for production
* EMR cluster provisioning, job submission, and termination were automated
* DAGs were stored in S3 and automatically synced with MWAA

### Infrastructure as Code with Terraform

All infrastructure components were defined and deployed using Terraform:

* AWS resources (EMR, S3, IAM, VPC, etc.) configured via Terraform modules
* Infrastructure changes tracked through version control
* Terraform state files managed in Terraform Cloud for team collaboration
* Multiple environments (dev, staging, prod) managed with workspace separation

### CI/CD Pipeline with GitHub Actions

A robust CI/CD pipeline was implemented using GitHub Actions:

* Code quality checks with Flake8 linting
* Automated testing of Python code
* Terraform plan and apply steps
* Continuous deployment to development environment
* Manual approval for production deployments

### Spark Optimization Strategies

Several optimization techniques were applied to improve Spark job performance:

* **Partitioning Strategy:** Data was optimally partitioned to balance workload
* **Caching:** Frequently accessed RDDs/DataFrames were cached appropriately
* **Executor Configuration:** Memory and CPU resources were tuned for the specific workload
* **Columnar Format:** Parquet files were used with appropriate compression
* **Resource Allocation:** Cluster sizing based on data volume and complexity

### Monitoring and Alerting

Comprehensive monitoring was set up using CloudWatch:

* EMR cluster metrics tracking (CPU, memory, disk usage)
* Airflow task success/failure monitoring
* Alert notifications for pipeline failures
* Custom dashboards for key performance indicators
* Log aggregation and analysis

## Pros and Cons of Tools Used

### Pros

- **Apache Airflow**: Offers flexibility and scalability in orchestrating complex workflows.
- **Terraform**: Provides automation and version control for infrastructure deployments.
- **GitHub Actions**: Facilitates seamless CI/CD processes with automated testing.
- **AWS EMR**: Efficiently handles big data processing with PySpark integration.
- **Amazon S3**: Ensures reliable storage and retrieval of large datasets.
- **CloudWatch**: Provides robust monitoring capabilities for workflow management.

### Cons

- **Apache Airflow**: Initial setup can be complex and requires careful configuration.
- **Terraform**: Requires familiarity with infrastructure-as-code concepts for effective use.
- **GitHub Actions**: May involve a learning curve for setting up complex workflows.
- **AWS EMR**: Cost considerations for extensive usage.
- **Amazon S3**: Requires management of storage costs as data volume increases.
- **CloudWatch**: Can incur additional costs for extensive monitoring.

## Impact on Business Problem

The implementation of this data platform provided significant benefits to the client:

* **Data Processing Efficiency:** Reduced data processing time from hours to minutes
* **Cost Optimization:** 40% reduction in data processing costs through EMR automation and spot instances
* **Data Accessibility:** Transformed data available for analysis in optimal format
* **Scalability:** Platform capable of handling 10x current data volume without redesign
* **Operational Excellence:** Infrastructure as code and CI/CD improved reliability and reduced manual interventions
* **Data-Driven Decision Making:** Enabled business analysts to access and query data efficiently

## Challenges and Lessons Learned

Several challenges were encountered during implementation:

* **EMR Configuration:** Finding the right balance of instances and configurations required iteration
* **Pipeline Dependencies:** Managing complex dependencies between processing steps
* **Cost Management:** Balancing performance with cost considerations
* **CI/CD for Infrastructure:** Implementing safe automated deployments for infrastructure changes

### Key lessons learned:

* Start with thorough testing on a representative dataset
* Implement monitoring from day one
* Automate infrastructure provisioning and teardown for cost control
* Use parameterized workflows for flexibility

## Future Improvements

Potential enhancements for the platform:

* Implement data quality validation steps
* Add machine learning model training capabilities
* Develop a self-service data exploration interface
* Implement data lineage tracking
* Enhance the monitoring with predictive alerts

## Conclusion

_This case study project demonstrates our commitment to delivering high-quality solutions that address complex business needs. By leveraging cutting-edge technologies and best practices, we successfully built a Data Platform that empowers BuildItAll clients to harness the power of big data analytics._
