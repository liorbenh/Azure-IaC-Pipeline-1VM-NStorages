# Creating an Azure Service Connection (Automatic Service principal, Subscription Scope)

Service Connection will allow your pipeline to authenticate to Azure.

## Prerequisites

Before creating an Azure Service Connection, ensure the following:

### Azure AD Role

- You must have the necessary Azure AD role to create a Service Principal or manage Azure resources, such as:
  - **Owner** or **Contributor** with **Role Based Access Control Administrator** roles on the target subscription.
- see **Setting Up Privileges for the Azure Subscription** below for further information.

### Azure DevOps Role

- You must have the "Project Administrator" or an equivalent role in the Azure DevOps project.

---

## Steps to Create an Azure Service Connection

### Step 1: Go to Project Settings

1. Log in to Azure DevOps.
2. Navigate to your project.
3. In the left-hand menu, click **Project settings** (located in the bottom-left corner).

### Step 2: Open Service Connections

1. Under the **Pipelines** section, click **Service connections**.
2. Click the **New service connection** button.

### Step 3: Choose Connection Type

1. In the "New service connection" pop-up, select **Azure Resource Manager**.
2. Click **Next**.

### Step 4: Configure the Connection

- **Authentication Method**:
  - Select **Service principal (automatic)**.
  - Azure DevOps will automatically create a Service Principal in Azure AD and assign the necessary permissions.
- **Subscription**:
  - Select your Azure subscription from the dropdown menu.
- **Resource Scope**:
  - Keep it at the subscription level for broad access.
- **Service Connection Name**:
  - Provide a name according to the following format: `ASC-<subproject>` (e.g. `ASC-test-Connection`).
  - the name must follow the format and the values given must be identical to the values given for these variables at the variables group defined.
  - NOTICE: the pipelines follow and adhere to this standard.
- **Restrict Pipeline Access**:
  - You can either enable `Grant access permission to all pipelines`, so you do not need to grant permission manually per pipeline, or use a granular approach and explicitly allow pipelines (after creating them) to use the service connection:
    - Go to the **Service Connections** page in **Project Settings**.
    - Click the service connection.
    - Click the **Security** tab.
    - Add the pipelines to the Reader role to grant access.
- Click **Save**.
---

## Verifying the Service Connection

Once the service connection is created, verify it to ensure it works correctly:

1. Go to the **Service connections** list.
2. Find your newly created service connection.
3. Click the three dots (**...**) next to it and select **Verify**.
4. Ensure the verification succeeds.

---


## Setting Up Privileges for the Service Connection

To have the service connection work successfully, the service connection must have certain privileges:

1. Go to **Azure portal -> Subscriptions -> \<selected subscription\> -> Access Control (IAM)**.
2. Click **Add role assignment** (or **+ Add > Add role assignment**).
3. In the **Role** section click on **Privileged administrator roles** , select the followings roles:
   - **Contributor** (for full management of resources).
   - **Role Based Access Control Administrator** (RBAC) (for the ability to grant other resources the capability to update permissions <br>[i.e. Storage updates VM managed Identity with storage read/write permissions])
4. In the **Members** section choose **User, group, or service principal** under **Assign access to**.
   Click on select **+Select members** and search the app **Display name**<br>.
   the app display name for service connection can be found here: **Azure Devops -> <Your Project\> -> Project settings -> Service connections -> <Your serice connection\> -> Manage App registration -> Display name (under Essentials)**<br>
   Once Added the app to as member, finish up creating.
   (for RBAC **Condition** section appear - Choose  **Allow user to assign all roles except privileged administrator roles Owner, UAA, RBAC (Recommended)**)

---

## Setting Up Privileges for the Azure Subscription

To successfully create a service connection, the creator must have certain privileges:

1. Go to **Access Control (IAM)** for the selected subscription in the Azure portal.
2. Click **Add role assignment** (or **+ Add > Add role assignment**).
3. In the **Role** dropdown, select a suitable role, such as:
   - **Contributor** +  **Role Based Access Control Administrator**.
   - **Owner** (I'd recommend that since that's what I had as a creator)
   - A custom role with more limited permissions (Access Control (IAM) > **+ Add > Add custom role**).
4. In the **Assign access to** dropdown, select **User, group**.

---

With these steps, you can securely create and configure an Azure Service Connection in Azure DevOps.