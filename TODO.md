# Azure IAC Tasks

## High Priority

### Security & Authentication
- [ ] Replace VM password authentication with key pair authentication
  - Update infrastructure level (server) configuration
  - Modify pipelines level implementation

### DevOps & Deployment
- [ ] Improve file transfer mechanism
  - Implement storage account-based transfer between agent and VM
  - Document new transfer process

## Medium Priority

### Environment Setup
- [ ] Implement Python version management
  - Add validation stage for Python version
  - Create automatic update process to desired version

## Low Priority

### Infrastructure Improvements
- [ ] Enhance subnet configuration in Network ARM
  - Convert subnet variables to arrays
  - Enable multiple subnet definitions per virtual network

## Future Considerations

### Network Access Management
- [ ] Handle closed network scenarios
  - Review existing scripts in `scripts/setup_tools`
  - Design solution for systems without external network access
  - Implement blob storage for offline software distribution
  - Test and validate closed network deployment

---

> **Note**: Tasks are categorized by priority and domain. Mark tasks as complete using [x] when done.
