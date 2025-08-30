#!/bin/bash
# ACT validation script
# This script validates that ACT is properly configured and can run basic tests

set -e

echo "🔧 ACT Configuration Validation"
echo "==============================="

# Check if ACT is installed
if ! command -v act >/dev/null 2>&1; then
    echo "❌ ACT is not installed. Run 'make setup-act' first."
    exit 1
fi

echo "✅ ACT is installed"

# Check if configuration files exist
if [ ! -f .actrc ]; then
    echo "❌ .actrc configuration file missing"
    exit 1
fi

echo "✅ .actrc configuration found"

# Check if secrets file exists
if [ ! -f .act_secrets ]; then
    echo "⚠️  .act_secrets file missing. Using example file for validation only."
    echo "   Create .act_secrets with real tokens for actual testing."
fi

# Check if environment file exists
if [ ! -f .act_env ]; then
    echo "❌ .act_env environment file missing"
    exit 1
fi

echo "✅ .act_env environment file found"

# Check if event files exist
EVENT_FILES=(
    ".github/act-events/push-template-files.json"
    ".github/act-events/workflow-dispatch-dry-run.json"
    ".github/act-events/workflow-dispatch-custom-topic.json"
)

for event_file in "${EVENT_FILES[@]}"; do
    if [ ! -f "$event_file" ]; then
        echo "❌ Event file missing: $event_file"
        exit 1
    fi
done

echo "✅ All event files found"

# Validate JSON syntax of event files
echo "🔍 Validating event file JSON syntax..."
for event_file in "${EVENT_FILES[@]}"; do
    if ! python3 -m json.tool "$event_file" >/dev/null 2>&1; then
        echo "❌ Invalid JSON in: $event_file"
        exit 1
    fi
done

echo "✅ All event files have valid JSON syntax"

# Check if workflow file exists
WORKFLOW_FILE=".github/workflows/sync-template-files.yml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Sync workflow file missing: $WORKFLOW_FILE"
    exit 1
fi

echo "✅ Sync workflow file found"

# Test ACT can list workflows
echo "🔍 Testing ACT workflow listing..."
if ! act --list >/dev/null 2>&1; then
    echo "❌ ACT cannot list workflows. Check configuration."
    exit 1
fi

echo "✅ ACT can list workflows"

# Display available workflows
echo ""
echo "📋 Available workflows for testing:"
act --list

echo ""
echo "🎉 ACT validation completed successfully!"
echo ""
echo "Next steps:"
echo "1. Edit .act_secrets with your GitHub token"
echo "2. Run 'make test-sync-workflow' to test the sync workflow"
echo "3. Run 'make test-workflows' to test all workflows"
echo ""
echo "For more information, see: docs/techdocs/docs/act-testing.md"