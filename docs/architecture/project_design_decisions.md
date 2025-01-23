# Project Design Decisions and Rationale

## 1. Network Access Assumptions for VM and Storage

There was some uncertainty about whether public access should be allowed for the VM and storage resources. 
To streamline the development process, I made an assumption that public access to the VM would be required, as the pipeline agent (my computer) is an external device and not part of a closed network with the VM. This assumption simplified the setup and allowed easier interaction between the components.
I assumed that the network between the server and storage components would remain closed to ensure security of data transferred, which kept storage accessible only through VM.

To facilitate the transfer of files (like `requirements.txt` and scripts from the Git repository) while ensuring secure access and streamlining the development process, I  decided to use the SCP protocal and copy the files to the VM directly, a more optimized approach would probably be to make another storage which would function as software packages setup container, and make it accessible both to inner network and outside network.<br>

In the case of a closed Network (Not accesible outside of the vnet) - Having the agent (In this, my computer) inside the vnet (Using vpn, or using an agent which is a vm) would have provided the necessary access for resources and file management without exposing the resources publicly (Potentially securing the resources better).

---

## 2. Naming Conventions for Resources

In terms of resource naming, To avoid confusion and ensure consistency, I decided to implement my own naming conventions. I wanted a standard that would improve automation and make the resources easy to manage. I took artistic liberty to create a naming system that made sense based on the project needs.<br>

While this approach helped with organization and clarity, I understand that the conventions could be debated, and the naming guidelines may need adjustments if certain project requirement  are introduced down the line.

---

## 3. Automating Blob Management

A key component of the CI/CD process is blob management,  I was not sure whether this task needed to be automated. But, realizing this task logically represents the ETL part of the process I assumed it is generally associated with automation.<br>

To ensure flexibility and meet potential CI/CD needs, I went ahead and automated the blob management process. The automation was integrated into the main pipeline, called the Orchestrator, allowing it to be executed as part of the larger workflow.<br>

Additionally, I gave the option to manually run blob management or trigger it from its dedicated pipeline, giving flexibility in how it can be handled. This dual approach provides both automation and manual control, allowing future adjustments if necessary.

---

These decisions were made to balance practicality with flexibility, ensuring the project could proceed without delays while staying open to future refinements as more specific requirements might arise.
