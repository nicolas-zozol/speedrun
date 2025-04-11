#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to commit changes in a submodule
commit_submodule() {
    local submodule=$1
    echo -e "\n${YELLOW}Processing $submodule...${NC}"
    cd "$submodule"
    
    # Check if there are changes to commit
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${GREEN}Committing changes in $submodule${NC}"
        git add -A
        git commit -m "Update $submodule"
        git push
    else
        echo -e "${GREEN}No changes to commit in $submodule${NC}"
    fi
    
    cd ..
}

# Process each submodule
for submodule in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'); do
    commit_submodule "$submodule"
done

# Update the parent repository with the new submodule commits
echo -e "\n${YELLOW}Updating parent repository...${NC}"
git add -A
git commit -m "Update submodules"
git push

echo -e "\n${GREEN}All changes have been committed and pushed!${NC}" 