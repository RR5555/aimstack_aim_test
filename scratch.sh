docker image inspect ubuntu:latest --format="exist" 2>/dev/null



stat ./TODO.md | awk '/^Modify:/ {print $2, " ", $3, " ", $4;}' | xargs -I {} date --date {}

stat -c '%y' ./TODO.md | xargs -I {} date --date {}



docker image inspect hello-world | jq '.[0].Metadata.LastTagTime' | xargs -I {} date --date {}
# OR
docker image inspect hello-world | jq '.[0].Created' | xargs -I {} date --date {}

# [bash - How to check if a Docker image with a specific tag exists locally? - Stack Overflow](https://stackoverflow.com/questions/30543409/how-to-check-if-a-docker-image-with-a-specific-tag-exists-locally)
# [xargs : construire des commandes à partir d'entrées](https://blog.stephane-robert.info/docs/admin-serveurs/linux/references/xargs/)
# [How to Use the stat Command to View File Metadata on Ubuntu](https://oneuptime.com/blog/post/2026-03-02-how-to-use-the-stat-command-to-view-file-metadata-on-ubuntu/view)
# [How to Compare Time in Shell | Baeldung on Linux](https://www.baeldung.com/linux/shell-compare-time#using-unix-epoch-time)

if [[ $(date --date="$last_location" +%s) < $(date --date="2022-05-20" +%s) ]]; then
    echo "before"
else
    echo "after"
fi


if [[ $(stat -c '%y' ./TODO.md | xargs -I {} date --date {} +'%s') > $(docker image inspect hello-world | jq '.[0].Created' | xargs -I {} date --date {} +'%s') ]]; then
    echo "SUCESS"
else
    echo "FAIL"
fi