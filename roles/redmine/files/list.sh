#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0);pwd)
OUT_FILE="$SCRIPT_DIR/list.yml"

echo "---" > $OUT_FILE

echo "- name: Redmine plugins (git)" >> $OUT_FILE
echo "  git: repo={{item.url}} dest={{redmine_home}}/plugins/{{item.name}} version={{item.rev}}" >> $OUT_FILE
echo "  with_items:" >> $OUT_FILE
for f in $(find $SCRIPT_DIR -name .git)
do
  pushd $(dirname $f)
  NAME=$(egrep 'Redmine::Plugin.register .+ do' init.rb | awk '{print $2}' | sed -e 's/://')
  URL=$(git remote -v | egrep 'origin.+fetch' | awk '{print $2}')
  REV=$(git branch | egrep '\*' | sed -e 's/\* //')
  echo "    - { name: $NAME, url: '$URL', version: $REV }" | tee -a $OUT_FILE
  popd
done

echo "- name: Redmine plugins (hg)" >> $OUT_FILE
echo "  hg: repo={{item.url}} dest={{redmine_home}}/plugins/{{item.name}} revision={{item.rev}}" >> $OUT_FILE
echo "  with_items:" >> $OUT_FILE
for f in $(find $SCRIPT_DIR -name .hg)
do
  pushd $(dirname $f)
  NAME=$(egrep 'Redmine::Plugin.register .+ do' init.rb | awk '{print $2}' | sed -e 's/://')
  URL=$(hg paths | awk '{print $3}')
  REV=$(hg branch)
  echo "    - { name: $NAME, url: '$URL', rev: $REV }" | tee -a $OUT_FILE
  popd
done
