#include "directory.h"
#include "inode.h"
#include "diskimg.h"
#include "file.h"
#include <stdio.h>
#include <string.h>
#include <assert.h>

/**
 * TODO
 */
int directory_findname(struct unixfilesystem *fs, const char *name,
		int dirinumber, struct direntv6 *dirEnt) {
  //Implement your code here
  struct inode dirinode;
  if (inode_iget(fs, dirinumber, &dirinode) < 0) {
      return -1;
  }

  if ((dirinode.i_mode & IFMT) != IFDIR) {
      return -1;
  }

  int filesize = inode_getsize(&dirinode);
  int nblocks = (filesize + DISKIMG_SECTOR_SIZE - 1) / DISKIMG_SECTOR_SIZE;

  char block[DISKIMG_SECTOR_SIZE];

  for (int b = 0; b < nblocks; b++) {
      int nbytes = file_getblock(fs, dirinumber, b, block);
      if (nbytes < 0) {
          return -1;
      }

      int nentries = nbytes / sizeof(struct direntv6);
      struct direntv6 *entry = (struct direntv6 *)block;

      for (int i = 0; i < nentries; i++) {
          char entry_name[15];
          memcpy(entry_name, entry[i].d_name, 14);
          entry_name[14] = '\0';

          if (strncmp(name, entry_name, 14) == 0) {
              *dirEnt = entry[i];
              return 0;
          }
      }
  }

  return -1;
}
