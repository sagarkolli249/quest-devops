# **Technical Reference Document (TRD)**

## **Deployment Architecture for Quest Service**

### **1. Overview**
This document provides a detailed explanation of the **approach taken** for deploying the **Quest Service** using AWS ECS (Elastic Container Service) instead of AWS Lambda, as originally planned. It also outlines the **ideal approach** that would have been taken if using Lambda, discussing the trade-offs and justifications for the changes made.

---

## **2. Approach Taken**

### **2.1 Description of the Implemented Architecture**
The chosen architecture uses **AWS ECS with Fargate**, **Elastic Load Balancer (ALB)**, **Elastic Container Registry (ECR)**, **CloudWatch Logs**, and **Terraform for infrastructure provisioning**. The key components are outlined in the **Mermaid Diagram** below:

mermaid
graph TD;

  subgraph AWS_Infrastructure
    VPC["VPC quest_vpc"] -->|Has| IGW["Internet Gateway quest_gw"]
    IGW -->|Routes Traffic| RT["Route Table quest_rt"]
    RT -->|Connected to| Subnet1["Subnet quest_subnet_1"]
    RT -->|Connected to| Subnet2["Subnet quest_subnet_2"]
  end

  subgraph Security_Groups
    ALB_SG["ALB Security Group alb_sg"]
    ECS_SG["ECS Security Group ecs_sg"]
  end

  subgraph IAM_Roles
    ECS_Exec_Role["IAM Role ecs_task_execution"]
  end

  subgraph Elastic_Container_Registry_ECR
    ECR["ECR Repository quest_container_repo"]
  end

  subgraph CloudWatch_Logs
    Logs["Log Group quest_task_logs"]
  end

  subgraph Application_Load_Balancer
    ALB["Application Load Balancer quest_alb"] -->|Forwards Traffic| TG["Target Group quest_tg"]
    ALB_SG -->|Security Applied| ALB
  end

  subgraph ECS_Cluster_Group
    ECS_Cluster["ECS Cluster quest_ecs"] -->|Manages| ECS_Service["ECS Service quest_service"]
    ECS_Service -->|Runs| ECS_Task["ECS Task quest_task"]
    ECS_Service -->|Registers to| TG
    ECS_Service --> ECS_SG
    ECS_Task -->|Logs to| Logs
    ECS_Task -->|Pulls Image from| ECR
    ECS_Task -->|Uses IAM Role| ECS_Exec_Role
  end

  Subnet1 -->|Networking| ALB
  Subnet2 -->|Networking| ALB
  Subnet1 -->|Networking| ECS_Service
  Subnet2 -->|Networking| ECS_Service

### **2.2 Justification for the Approach Taken**
Initially, the plan was to deploy the application as an **AWS Lambda function**. However, after evaluating constraints and requirements, the decision was made to transition to an **ECS (Elastic Container Service) approach using AWS Fargate**.

| Factor                | AWS Lambda                                    | ECS Fargate (Chosen)                      |
|-----------------------|---------------------------------------------|------------------------------------------|
| **Execution Model**   | Event-driven (cold starts, time limits)     | Persistent containerized workloads      |
| **State Management**  | Stateless, requires S3/DynamoDB for state   | Containers maintain state in-memory      |
| **Performance**       | Cold start latency in some cases            | Lower startup latency                    |
| **Networking**        | No persistent VPC IP, must use ALB          | Runs inside VPC with direct networking  |
| **Deployment**        | Runtime-specific packaging                  | Full Docker container support           |
| **Scaling**          | Automatic scaling, pay-per-execution        | Manual scaling, predictable compute     |
| **Cost Efficiency**   | Cheaper for small workloads                 | Better for long-running processes       |

### **Reasons for Choosing ECS Fargate**
- **Greater control over networking**: Lambda does not retain a **static IP**, making **outbound network filtering** more complex.
- **Long-running processes**: Lambda has a **15-minute execution limit**, whereas **ECS Fargate containers** can run **indefinitely**.
- **Easier debugging**: Containers **log to CloudWatch** and have **direct shell access**, making troubleshooting **simpler**.
- **More flexibility in application packaging**: Lambda requires **ZIP-based deployments**, whereas ECS supports **full Docker images**.

---

## **3. The Ideal Approach (If Using AWS Lambda)**

Had AWS Lambda been used, the approach would have been structured as follows:

mermaid
graph TD;
    subgraph AWS_Infrastructure
        subgraph Network
            VPC[VPC] -->|Contains| Subnets[Public & Private Subnets]
            Subnets --> SecurityGroups[Security Groups]
        end
        
        subgraph Compute
            Lambda[Lambda Function] --> IAMRole[Execution IAM Role]
        end
        
        subgraph Storage
            S3_State[S3 Bucket - Terraform State] --> DynamoDB[State Locking - DynamoDB]
            S3_Lambda[S3 Bucket - Lambda ZIP] --> Lambda
        end

        subgraph IAM
            IAMRole -->|Grants permissions to| Lambda
            IAMRole -->|Accesses| CloudWatch[CloudWatch Logs]
        end

        subgraph Load_Balancer
            ALB[Application Load Balancer] -->|Routes Traffic| TargetGroup[Target Group]
            TargetGroup -->|Forwards Requests| Lambda
        end
    end

    subgraph GitHub_Actions
        Push[Developer Pushes Code] --> CI_CD_Workflow[GitHub Actions Workflow]
        CI_CD_Workflow --> ZipLambda[Zip Lambda Code]
        ZipLambda --> UploadS3[Upload ZIP to S3]
        
        UploadS3 --> TerraformInit[Run Terraform Init]
        TerraformInit --> TerraformValidate[Run Terraform Validate]
        TerraformValidate --> TerraformLint[Run Terraform Lint]
        TerraformLint --> TerraformPlan[Run Terraform Plan]
        TerraformPlan --> TerraformApply[Run Terraform Apply]
        
        TerraformApply --> Lambda[Deploy New Lambda Version]
    end

    Terraform[Terraform IaC] -->|Provisions| Network
    Terraform -->|Provisions| Compute
    Terraform -->|Provisions| Storage
    Terraform -->|Provisions| IAM
    Terraform -->|Provisions| Load_Balancer

    CI_CD_Workflow --> Terraform[Trigger Terraform]

### **3.1 Why This Was the Ideal Approach for AWS Lambda**
- **GitHub Actions CI/CD Pipeline**
  - Automates **Terraform validation, formatting, and deployment**.
  - Ensures that **Lambda deployments** are uploaded to **S3** and provisioned using **Terraform**.
- **S3 + DynamoDB for State & Deployment**
  - **Terraform state** stored in **S3** ensures **version control**.
  - **Lambda deployment ZIP** stored in **S3** allows **faster updates**.
  - **DynamoDB ensures state-locking** for concurrent **Terraform runs**.
- **AWS ALB & API Gateway Integration**
  - The **ALB forwards HTTP traffic** to **Lambda via a Target Group**.
  - Alternatively, **API Gateway** could be used for finer-grained control.
- **Fully Managed Scaling**
  - **Lambda auto-scales automatically** based on request volume.
  - No need for **manual scaling** (as required in ECS).

---

## **4. Trade-offs and Challenges**

| Challenge                        | Solution Implemented                                  |
|----------------------------------|------------------------------------------------------|
| **Lambda Cold Starts**           | Moved to ECS to ensure **low-latency startup**.     |
| **Lambda Execution Limit (15min)** | ECS allows **indefinite runtime** for services.  |
| **No Static IP in Lambda**       | ECS runs **within a VPC**, allowing **better control**. |
| **Stateful Processing Needs**    | ECS allows **containers to maintain in-memory state**. |
| **Custom Dependencies**          | ECS uses **Docker images**, avoiding **Lambda layer** size limitations. |

---

## **5. Conclusion**
The **ECS-based approach** was chosen due to:
1. **More predictable performance** (**no cold starts, persistent compute**).
2. **More control over networking** (**ECS containers live within a VPC**).
3. **Better debugging capabilities** (**logs, direct shell access via AWS Fargate**).
4. **Support for long-running tasks** (**ECS can run continuously, unlike Lambda’s 15-minute limit**).

However, **AWS Lambda would have been ideal** for:
- **Short-lived functions with minimal state**.
- **Minimizing costs for infrequent executions**.
- **Using AWS API Gateway instead of ALB**.

---

## **6. Next Steps**
- Evaluate **ECS Auto Scaling** for **cost optimization**.
- Implement **Terraform state locking** with **DynamoDB**.
- Integrate **CI/CD workflows** to automate **container builds and deployments**.

This TRD serves as a reference for the **design decisions and trade-offs** made in moving from **Lambda to ECS** and will inform future **infrastructure decisions**. 🚀
