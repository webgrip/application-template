# GitHub Actions Testing with ACT

This repository includes support for testing GitHub Actions workflows locally using [ACT](https://github.com/nektos/act), which allows you to run workflows in Docker containers without pushing to GitHub.

## Quick Start

1. **Setup ACT**: Build ACT Docker image and create local configuration
   ```bash
   make setup-act
   ```

2. **Configure secrets**: Edit `.act_secrets` with your GitHub token
   ```bash
   # Copy the example and add your token
   cp .act_secrets.example .act_secrets
   # Edit .act_secrets and add your GitHub personal access token
   ```

3. **Test workflows**: Run workflow tests locally
   ```bash
   # Test the template sync workflow (dry run)
   make test-sync-workflow
   
   # Test all workflows
   make test-workflows
   ```

## Prerequisites

- **Docker**: ACT runs workflows in Docker containers, so Docker must be installed and running
- **GitHub Token**: A personal access token with `repo` permissions for API access

## Available Testing Commands

### Setup and Configuration
- `make build-act` - Build ACT Docker image locally
- `make setup-act` - Build ACT Docker image and setup testing environment
- `make validate-act` - Validate ACT configuration and dependencies
- `make list-workflows` - List all available workflows for testing

### Testing Workflows
- `make test-sync-workflow` - Test sync-template-files workflow with dry run
- `make test-sync-push` - Test sync workflow triggered by push event
- `make test-workflows` - Test all GitHub Actions workflows locally

### Cleanup
- `make clean-act` - Clean ACT output and temporary files

## Configuration Files

### `.actrc`
Main ACT configuration file that sets:
- Runner images (Ubuntu versions)
- Default branch and event settings
- Secrets and environment file locations
- Container options

### `.act_secrets`
Contains sensitive values needed by workflows:
- `GITHUB_TOKEN` - GitHub personal access token with repo permissions
- Add other secrets as needed by your workflows

### `.act_env`
Environment variables available to all workflows during testing.

### Event Files (`.github/act-events/`)
Pre-configured event payloads for different trigger scenarios:
- `push-template-files.json` - Simulates push to template files
- `workflow-dispatch-dry-run.json` - Manual trigger with dry run
- `workflow-dispatch-custom-topic.json` - Manual trigger with custom topic

## Testing the Template Sync Workflow

The template synchronization workflow can be tested in several ways:

### 1. Dry Run Test (Recommended)
```bash
make test-sync-workflow
```
This uses the `workflow-dispatch-dry-run.json` event file to trigger the workflow with `dry_run: true`, which will:
- Find repositories with the `application` topic
- Show what files would be synced
- Not make any actual changes

### 2. Push Event Test
```bash
make test-sync-push
```
This simulates a push event that would trigger the workflow when template files are modified.

### 3. Custom Testing
You can run ACT directly with custom parameters using the local Docker image:
```bash
# Test with specific workflow file
docker run --rm -v $(PWD):/workspace -w /workspace \
  --secret-file .act_secrets --env-file .act_env \
  application-template-act:latest workflow_dispatch \
  --eventpath .github/act-events/workflow-dispatch-custom-topic.json \
  --workflows .github/workflows/sync-template-files.yml

# Test with specific event
docker run --rm -v $(PWD):/workspace -w /workspace \
  --secret-file .act_secrets --env-file .act_env \
  application-template-act:latest push \
  --eventpath .github/act-events/push-template-files.json
```

## Troubleshooting

### Common Issues

1. **Missing GitHub token**: Make sure `.act_secrets` contains a valid `GITHUB_TOKEN`
2. **Docker not running**: ACT requires Docker to be running  
3. **ACT image not built**: Run `make setup-act` to build the ACT Docker image
4. **Large runner images**: First run downloads ~1GB of runner images
5. **API rate limits**: Use a GitHub token to avoid API rate limiting

### Debug Mode
Run ACT with verbose output for debugging:
```bash
docker run --rm -v $(PWD):/workspace -w /workspace \
  --secret-file .act_secrets --env-file .act_env \
  application-template-act:latest --verbose workflow_dispatch \
  --eventpath .github/act-events/workflow-dispatch-dry-run.json
```

### Viewing Workflow Output
ACT saves artifacts and outputs to `./act_output/` directory. Check this directory for:
- Step outputs and logs
- Artifact files
- Error messages

## Security Notes

- **Never commit `.act_secrets`** - This file contains sensitive tokens
- Use personal access tokens with minimal required permissions
- For testing, use tokens with only `repo` scope
- Rotate tokens regularly and revoke unused tokens

## Integration with CI/CD

This ACT setup can be integrated into your development workflow:

1. **Pre-commit testing**: Test workflows before pushing changes
2. **Local development**: Iterate on workflow changes quickly
3. **Debugging**: Troubleshoot workflow issues without multiple commits
4. **Documentation**: Verify workflow behavior matches documentation

## Advanced Usage

### Custom Event Payloads
Create custom event files in `.github/act-events/` for specific test scenarios:

```json
{
  "inputs": {
    "topic": "my-custom-topic",
    "dry_run": "false"
  },
  "ref": "refs/heads/feature-branch"
}
```

### Environment Variable Overrides
Override environment variables for specific tests:
```bash
docker run --rm -v $(PWD):/workspace -w /workspace \
  --secret-file .act_secrets --env-file .act_env \
  -e GITHUB_REPOSITORY=myorg/myrepo \
  -e CUSTOM_VAR=test-value \
  application-template-act:latest workflow_dispatch
```

### Multiple Workflow Testing
Test multiple workflows in sequence:
```bash
# Test specific workflows only
docker run --rm -v $(PWD):/workspace -w /workspace \
  --secret-file .act_secrets --env-file .act_env \
  application-template-act:latest push --workflows .github/workflows/sync-template-files.yml

docker run --rm -v $(PWD):/workspace -w /workspace \
  --secret-file .act_secrets --env-file .act_env \
  application-template-act:latest push --workflows .github/workflows/on_docs_change.yml
```

## Resources

- [ACT Documentation](https://github.com/nektos/act)
- [GitHub Actions Events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)
- [Workflow Testing Best Practices](https://docs.github.com/en/actions/automating-builds-and-tests/about-continuous-integration)