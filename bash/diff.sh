#!/bin/bash

# 获取分支名
BRANCH1="master"
BRANCH2="hotfix/aioa-08"

echo "比较分支 $BRANCH1 和 $BRANCH2 的差异:"

# 输出文件名
OUTPUT_FILE="git_diff_output.txt"

# 清空输出文件以便重新写入
> "$OUTPUT_FILE"

# 输出两个分支之间的 diff
echo "比较分支 $BRANCH1 和 $BRANCH2 的差异:" >> "$OUTPUT_FILE"
git diff "$BRANCH1".."$BRANCH2" >> "$OUTPUT_FILE"

# 输出新增的文件
echo -e "\n新增的文件:\n" >> "$OUTPUT_FILE"
git diff --name-only "$BRANCH1".."$BRANCH2" --diff-filter=A >> "$OUTPUT_FILE"

# 完成提示
echo "差异和新增文件已输出到 $OUTPUT_FILE"