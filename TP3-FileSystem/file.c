#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include "file.h"
#include "inode.h"
#include "diskimg.h"

/**
 * TODO
 */
int file_getblock(struct unixfilesystem *fs, int inumber, int blockNum, void *buf) {
    struct inode in;
    if (inode_iget(fs, inumber, &in) < 0) {
        return -1;
    }

    int dataBlockNum = inode_indexlookup(fs, &in, blockNum);
    if (dataBlockNum == -1) {
        return -1;
    }

    if (diskimg_readsector(fs->dfd, dataBlockNum, buf) < 0) {
        return -1;
    }

    int fileSize = inode_getsize(&in);
    int totalFullBlocks = fileSize / DISKIMG_SECTOR_SIZE;
    int remainder = fileSize % DISKIMG_SECTOR_SIZE;

    if (blockNum < totalFullBlocks) {
        return DISKIMG_SECTOR_SIZE;
    } else if (blockNum == totalFullBlocks) {
        return remainder;
    } else {
        return 0;
    }
}

