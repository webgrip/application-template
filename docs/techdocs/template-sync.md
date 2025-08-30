# Template File Synchronization

This template repository includes an automated workflow to sync template files to application repositories based on GitHub topics.

## Overview

The template sync workflow automatically keeps certain template files up-to-date across multiple application repositories in your organization. This eliminates the need to manually copy workflow files, configuration files, and documentation updates to each application repository.

## How It Works

1. **Topic-based targeting**: Repositories are identified for sync based on GitHub topics
2. **Automated pull requests**: Changes are proposed via pull requests, allowing for review
3. **Selective file sync**: Only specific template files are synchronized
4. **Conflict-aware**: Existing customizations are preserved through the PR review process

## Files That Are Synced

The following files are automatically synchronized from the template to target repositories:

### Workflow Files
- `.github/workflows/on_docs_change.yml` - Documentation deployment workflow
- `.github/workflows/on_source_change.yml` - Source code build and deployment workflow  
- `.github/workflows/on_workflow_files_change.yml` - Workflow file change handling

### Configuration Files
- `.editorconfig` - Editor configuration for consistent code formatting
- `.gitignore` - Git ignore patterns
- `.releaserc.json` - Semantic release configuration

### Development Tools
- `.vscode/settings.json` - VSCode workspace settings

## Setting Up Template Sync

### For Application Repositories

To enable template sync for an application repository:

1. **Add the topic**: Add the `app-template-sync` topic to your repository
   - Go to your repository settings
   - In the "Topics" section, add `app-template-sync`
   - Save the changes

2. **Initial sync**: The next time the template repository is updated, your repository will receive a pull request with the synced files

### For the Template Repository

The sync workflow is automatically triggered when:
- Template files are changed and pushed to the `main` branch
- The workflow can also be manually triggered from the Actions tab

## Manual Sync

You can manually trigger a sync from the template repository:

1. Go to the Actions tab in the template repository
2. Select the "Sync Template Files to Application Repos" workflow
3. Click "Run workflow"
4. Optionally specify:
   - **Topic**: Custom topic to filter repositories (default: `app-template-sync`)
   - **Dry run**: Preview what would be synced without making changes

## Customization and Conflicts

### Handling Conflicts

When template files are synced:
1. A new branch is created in the target repository
2. Template files are copied, preserving any existing customizations not in conflict
3. A pull request is created for review
4. Repository maintainers can review and merge the changes as appropriate

### Repository-Specific Customizations

If you need to customize template files for specific repositories:

1. **Review the PR**: When a sync PR is created, review the changes carefully
2. **Modify as needed**: Make any necessary modifications in the PR or after merging
3. **Document customizations**: Consider documenting why certain customizations were made

### Opting Out

To stop receiving template sync updates:
1. Remove the `app-template-sync` topic from your repository
2. Existing sync PRs can be closed without merging

## Workflow Configuration

The sync workflow is defined in `.github/workflows/sync-template-files.yml` and includes:

- **Automatic triggers**: Runs when template files are modified
- **Topic detection**: Uses GitHub GraphQL API to find repositories with the specified topic
- **Safe operations**: Creates branches and PRs instead of direct pushes
- **Error handling**: Continues processing other repositories if one fails

## Troubleshooting

### No Repositories Found
If the workflow reports "No repositories found":
- Verify the `app-template-sync` topic is added to target repositories
- Check that repositories are in the same organization as the template
- Ensure the GitHub token has sufficient permissions

### Sync Failures
If sync fails for a specific repository:
- Check the workflow logs for specific error messages
- Verify the target repository allows PR creation
- Ensure there are no branch protection rules blocking the sync branch creation

### Customizations Lost
If repository-specific customizations are overwritten:
- The changes should be visible in the PR diff
- Restore customizations by modifying the PR before merging
- Consider documenting customizations for future reference

## Example Use Cases

1. **Workflow Updates**: When CI/CD workflows are improved in the template, all application repositories can receive the updates
2. **Security Updates**: Security-related workflow changes can be quickly distributed
3. **Tooling Changes**: Updates to development tools and configurations can be synchronized
4. **Documentation**: Template documentation updates can be shared across projects

## Best Practices

1. **Review PRs carefully**: Always review sync PRs to ensure compatibility with your application
2. **Test changes**: Test workflow and configuration changes in a development environment
3. **Document customizations**: Keep track of application-specific modifications
4. **Use semantic commits**: The sync workflow follows conventional commit patterns
5. **Regular maintenance**: Periodically review and update the list of synced files