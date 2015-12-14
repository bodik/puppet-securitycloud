dpkg -l elasticsearch 1>/dev/null 2>/dev/null
if [ $? -eq 0 ]; then
        echo "INFO: SECURITYCLOUDIPFIXCOLNODECHECK ======================="

        echo "INFO: pa.sh -v --noop --show_diff -e 'include securitycloud::ipfixcol_node'"
        pa.sh -v --noop --show_diff -e 'include securitycloud::ipfixcol_node'
fi
