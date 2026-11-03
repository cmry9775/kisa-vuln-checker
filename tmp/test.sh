cd /tmp
printf '#!/usr/bin/env bash\nsleep 6\n' > U-91.sh
printf '#!/usr/bin/env bash\necho "boom" >&2; exit 3\n' > U-92.sh
printf '#!/usr/bin/env bash\necho "cat: /etc/shadow: Permission denied" >&2; exit 1\n' > U-93.sh
printf '#!/usr/bin/env bash\necho not-json\n' > U-94.sh
printf '#!/usr/bin/env bash\nsource "/e/프로젝트/kisa-vuln-checker/lib/common.sh"\nemit U-95 ok 상 양호 ev fix\n' > U-95.sh
printf '#!/usr/bin/env bash\nsource "/e/프로젝트/kisa-vuln-checker/lib/common.sh"\nemit U-96 okrc 상 양호 ev fix; exit 1\n' > U-96.sh
ls /tmp/U-*.sh