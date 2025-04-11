#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking parent repository status...${NC}"
git status

echo -e "\n${YELLOW}Checking submodules status...${NC}"
for submodule in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'); do
    echo -e "\n${GREEN}Checking $submodule...${NC}"
    cd "$submodule"
    
    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${RED}Uncommitted changes in $submodule:${NC}"
        git status
    else
        echo -e "${GREEN}No uncommitted changes in $submodule${NC}"
    fi
    
    # Check if submodule is at the latest commit
    git fetch
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    BASE=$(git merge-base @ @{u})
    
    if [ $LOCAL = $REMOTE ]; then
        echo -e "${GREEN}Submodule is up to date${NC}"
    elif [ $LOCAL = $BASE ]; then
        echo -e "${YELLOW}Submodule needs to be pulled${NC}"
    elif [ $REMOTE = $BASE ]; then
        echo -e "${YELLOW}Submodule has unpushed commits${NC}"
    else
        echo -e "${RED}Submodule has diverged${NC}"
    fi
    
    cd ..
done

echo -e "\n${YELLOW}Submodule summary:${NC}"
git submodule status 