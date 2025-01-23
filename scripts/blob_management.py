import argparse
import time

from datetime import datetime, timedelta
import pytz
from azure.storage.blob import BlobServiceClient, generate_blob_sas, BlobSasPermissions, ContainerClient
from azure.core.exceptions import ResourceExistsError
from azure.identity import ManagedIdentityCredential

DEFAULT_CONTAINER_NAME = "blobdefaultcontainer"
BLOB_CONTENT = "Sample blob content."

def create_container(service_client: BlobServiceClient, container_name: str) -> ContainerClient:
    try:
        print(f"Creating container {container_name}.")
        container_client = service_client.create_container(container_name)
    except ResourceExistsError:
        container_client = service_client.get_container_client(container_name)
        print(f"Container {container_name} already exists.")
    return container_client

def upload_blobs(container_client: ContainerClient):
    for i in range(1, 101):
        blob_name = f"blob_{i}.txt"
        blob_client = container_client.get_blob_client(blob_name)
        blob_client.upload_blob(BLOB_CONTENT, overwrite=True)
    print(f"Uploaded 100 blobs to {container_client.account_name}.")

def copy_blobs(container_client_src: ContainerClient, container_client_dest: ContainerClient, src_user_delegation_key):
    for blob in container_client_src.list_blobs():
        source_blob = container_client_src.get_blob_client(blob.name)
        
        # Generate SAS token for the source blob
        sas_token = generate_blob_sas(
            account_name=container_client_src.account_name,
            container_name=container_client_src.container_name,
            blob_name=source_blob.blob_name,
            permission=BlobSasPermissions(read=True),
            expiry=datetime.now(pytz.utc) + timedelta(hours=1),
            user_delegation_key=src_user_delegation_key
        )
        
        source_blob_url_with_sas = f"{source_blob.url}?{sas_token}"
        dest_blob = container_client_dest.get_blob_client(blob.name)
        dest_blob.start_copy_from_url(source_blob_url_with_sas)
        
        props = dest_blob.get_blob_properties()
        while props.copy.status == 'pending':
            time.sleep(1)
            props = dest_blob.get_blob_properties()

def main(src_storage_account: str = None, dest_storage_accounts: str = None, container_name: str = DEFAULT_CONTAINER_NAME, upload: bool = False):
    if src_storage_account:
        print(f"Creating container {container_name} in {src_storage_account}.")
        credential = ManagedIdentityCredential()  # Use ManagedIdentityCredential to authenticate
        src_service_client = BlobServiceClient(account_url=f"https://{src_storage_account}.blob.core.windows.net", credential=credential)
        src_container_client = create_container(src_service_client, container_name)
        
        # Get user delegation key
        src_service_client_user_delegation_key = src_service_client.get_user_delegation_key(
            key_start_time=datetime.now(pytz.utc),
            key_expiry_time=datetime.now(pytz.utc) + timedelta(hours=1)
        )
    else:
        raise ValueError("Source storage account name is required.")
    
    if upload:
        print(f"Uploading blobs to {src_storage_account}/{container_name}.")
        upload_blobs(src_container_client)
    
    if dest_storage_accounts:
        for dest_storage_account in dest_storage_accounts.split(','):
            dest_storage_account = dest_storage_account.strip()
            if dest_storage_account:
                print(f"Copying blobs from {src_storage_account}/{container_name} to {dest_storage_account}/{container_name}.")
                dest_service_client = BlobServiceClient(account_url=f"https://{dest_storage_account}.blob.core.windows.net", credential=credential)
                dest_container_client = create_container(dest_service_client, container_name)
                copy_blobs(src_container_client, dest_container_client, src_service_client_user_delegation_key)
                print(f"Copy operation to {dest_storage_account}/{container_name} completed.")

def _check_empty_str(value: str) -> str:
    return None if value == '' else value

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Manage Azure Blob Storage operations.")
    parser.add_argument('--src-storage', required=True, help="Source storage account name.")
    parser.add_argument('--dest-storage', required=False, help="Comma-separated list of destination storage account names.")
    parser.add_argument('--container-name', required=False, default=DEFAULT_CONTAINER_NAME, help="Name of the storage container.")
    parser.add_argument('--upload', action='store_true', help="Flag to upload blobs to the source storage account.")
    args = parser.parse_args()
    
    # Check if arguments are empty strings and set them to None
    src_storage_account = _check_empty_str(args.src_storage)
    dest_storage_accounts = _check_empty_str(args.dest_storage)
    container_name = _check_empty_str(args.container_name)
    
    main(src_storage_account, dest_storage_accounts, container_name, args.upload)
