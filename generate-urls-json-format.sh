# 1. Generate the combined JSON file from your API call
./get-repo-urls.sh > all_repos.json

# 2. Create the projects directory
mkdir -p repos

# 3. Split the array into individual files
jq -c '.[]' all_repos.json | while read -r line; do
    # Extract the name from the URL for the filename
    name=$(echo "$line" | jq -r '.url | split("/") | last | rtrimstr(".git")')
    
    # Create the object with name and url
    echo "$line" | jq --arg n "$name" '. + {name: $n, path: "."}' > "repos/${name}.json" > "repos/${name}.json"
done
