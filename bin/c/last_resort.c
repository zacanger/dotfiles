#include <unistd.h>
#include <linux/reboot.h>
int main(){
  sync();
  reboot(LINUX_REBOOT_CMD_POWER_OFF);
  perror("reboot");
}
