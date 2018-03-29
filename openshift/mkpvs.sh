sudo -i

export EXPORT_DIR=/exports

# Mounting the Cinder volume for NFS storage

mkfs -t ext4 /dev/vdc
mkdir ${EXPORT_DIR}
mount /dev/vdc ${EXPORT_DIR}
echo /dev/vdc ${EXPORT_DIR} ext4 defaults 0 0 >> /etc/fstab

# Creating NFS mounts

cd ${EXPORT_DIR}
mkdir pv-fs-neo4j-data
mkdir pv-fs-neo4j-data-loader
mkdir pv-fs-neo4j-log
mkdir pv-fs-pg-data
mkdir pv-fs-cartridge-data
mkdir pv-fs-web-log
mkdir pv-fs-web-media
chmod -R 777 pv-*
chown -R nfsnobody.nfsnobody pv-*

# Note the use of (rw,sync,no_subtree_check,no_root_squash)
# for the postgres volumes!
# See https://github.com/kubernetes/kubernetes/issues/54601

cd /etc/exports.d/
echo ${EXPORT_DIR}/pv-fs-neo4j-data *(rw,root_squash) >> frag.exports
echo ${EXPORT_DIR}/pv-fs-neo4j-data-loader *(rw,root_squash) >> frag.exports
echo ${EXPORT_DIR}/pv-fs-neo4j-log *(rw,root_squash) >> frag.exports
echo ${EXPORT_DIR}/pv-fs-pg-data *(rw,sync,no_subtree_check,no_root_squash) >> frag.exports
echo ${EXPORT_DIR}/pv-fs-cartridge-data *(rw,sync,no_subtree_check,no_root_squash) >> frag.exports
echo ${EXPORT_DIR}/pv-fs-web-log *(rw,root_squash) >> frag.exports
echo ${EXPORT_DIR}/pv-fs-web-media *(rw,root_squash) >> frag.exports

systemctl restart nfs-server
showmount -e localhost
