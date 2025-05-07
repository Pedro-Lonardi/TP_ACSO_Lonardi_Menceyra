#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include "inode.h"
#include "diskimg.h"
#include "unixfilesystem.h"
#include "ino.h"



/**
 * TODO
 */
int inode_iget(struct unixfilesystem *fs, int inumber, struct inode *inp) {
    //Implement Code Here
    // Validación del inumber (comienza en 1)
    if (inumber < 1 || inumber > fs->superblock.s_isize * (DISKIMG_SECTOR_SIZE / sizeof(struct inode))) {
        return -1;
    }

    int inumber0 = inumber - 1;
    int blockNum = inumber0 / (DISKIMG_SECTOR_SIZE / sizeof(struct inode));
    int offset = inumber0 % (DISKIMG_SECTOR_SIZE / sizeof(struct inode));

    char buffer[DISKIMG_SECTOR_SIZE];
    if (diskimg_readsector(fs->dfd, INODE_START_SECTOR + blockNum, buffer) < 0) {
        return -1;
    }

    struct inode *inodeBlock = (struct inode *)buffer;
    *inp = inodeBlock[offset];

    return 0;
}

/**
 * TODO
 */
int inode_indexlookup(struct unixfilesystem *fs, struct inode *inp, int blockNum) {  
    //Implement code here
    if ((inp->i_mode & IALLOC) == 0) {
        return -1; // inode not allocated
    }

    if ((inp->i_mode & ILARG) == 0) {
        // archivo "pequeño": bloques directos
        if (blockNum < 0 || blockNum >= 8) {
            return -1;
        }
        return inp->i_addr[blockNum];
    } else {
        // archivo "grande": bloques indirectos
        if (blockNum < 0 || blockNum >= 7 * 256 + 256 * 256) {
            return -1;
        }

        if (blockNum < 7 * 256) {
            int indirBlockIndex = blockNum / 256;
            int indirBlockOffset = blockNum % 256;

            uint16_t indir[256];
            if (diskimg_readsector(fs->dfd, inp->i_addr[indirBlockIndex], (char *)indir) < 0) {
                return -1;
            }
            return indir[indirBlockOffset];
        } else {
            int adjusted = blockNum - 7 * 256;
            int indir1 = adjusted / 256;
            int indir2 = adjusted % 256;

            uint16_t firstLevel[256];
            if (diskimg_readsector(fs->dfd, inp->i_addr[7], (char *)firstLevel) < 0) {
                return -1;
            }

            uint16_t secondLevel[256];
            if (diskimg_readsector(fs->dfd, firstLevel[indir1], (char *)secondLevel) < 0) {
                return -1;
            }

            return secondLevel[indir2];
        }
    }
}

int inode_getsize(struct inode *inp) {
  return ((inp->i_size0 << 16) | inp->i_size1); 
}
