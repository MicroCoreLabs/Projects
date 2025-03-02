# XTMax Device Drivers

## BIOS Extension ROM for SD Card (BootROM)

The XTMax maps a BIOS Extension ROM at address 0xCE000-0xCE7FF, plus a bank of registers at address 0xCE800-0xCEFFF.

The BIOS Extension ROM presents the SD Card on the Teensy as a fixed disk drive that can be used for booting and/or for
storage in MS-DOS and other operating systems using INT13h fixed disk services (note: OS/2 does not use INT13h fixed
disk services and therefore cannot use the SD Card).

The ROM can be relocated by changing the address `BOOTROM_ADDR` in the [`bootrom.h`](../Code/XTMax/bootrom.h) and
re-deploying the Teensy sketch. The address **must** be a multiple of 2048 bytes (2KB) and must be within the range
0xC8000-DF800 (this is the range that the BIOS searches).

### Preparing an SD Card for use with MS-DOS

The preferred method for preparing an SD Card for use is to use the machine with the XTMax. From an MS-DOS prompt, begin
with re-writing the Master Boot Record (MBR) onto the SD Card. This is needed in order to make sure that the SD Card can
be used for booting. Modern devices are shipped pre-formatted with an MBR that is not compatible with older x86
micro-processors.

```
A:\> FDISK /MBR
```

Next, partitions can be created on the SD Card with `FDISK`.

```
A:\> FDISK
```

If there is another fixed disk drive, be sure to select the correct drive from the `FDISK` menu. The existing partition
on the SD Card must first be deleted, before creating a new Primary Partition. **This will destroy the entire content of
the SD Card**. The new Primary Partition must be set as Active if the SD Card must be used for booting.

The partition on the SD Card will now appear as a new logical drive, typically `C:` or `D:` depending on availability.

Finally, the partition must be formatted. Use `FORMAT` and use the `/S` switch if the SD Card must be used for booting.

Note: MS-DOS will typically limit a partition size to 2GB. However, it is possible to create 3 additional Extended
Partitions to increase the usage of the SD Card. These partitions will appear as new logical drives, such as `E:`, `F:`,
etc... depending on availability.

## MS-DOS Driver for SD Card (XTSD)

This driver is provided as a back-up option for machines without support for BIOS Extension ROMs. It is based on the
[SDPP](https://github.com/nilseuropa/sdpp) driver originally written by Robert Armstrong and later improved by Dan
Marks.

**This driver is not necessary when the BIOS Extension ROM is loaded by the BIOS during boot.**

The device driver can be found here: [`XTSD.SYS`](https://raw.githubusercontent.com/MicroCoreLabs/Projects/master/XTMax/Drivers/XTSD.SYS).
Once downloaded, it must be placed on a drive accessible during boot and must be invoked from `CONFIG.SYS` as shown in
the example below:

```
DEVICE=A:\XTSD.SYS
```

When loaded, the driver will create a new logical drive for the SD Card, typically `C:` or `D:` depending on
availability.

### Preparing an SD Card for use with MS-DOS

The SD Card can be prepared from another machine. In this example, the SD Card is prepared from a Windows 10/11 machine.

Use `DISKPART`. First, use `LIST DISK` to find the disk number of the SD Card then `SELECT DISK #` with the appropriate
disk number.

Next, use `CLEAN` to delete all partitions. **This will destroy the entire content of the SD Card**.

Finally, create a new partition with `CREATE PART PRIMARY SIZE=#` by specifying the desired partition size in MB.
Depending on the version of MS-DOS on the machine that will be using the SD Card, there are limit on the size (typically
2048 ie 2GB).

The partition must be formatted, for example with `FORMAT #: /FS:FAT /Q`.

## EMS Driver for MS-DOS (XTEMM)

This driver provides LIM 4.0 Expanded Memory (EMS) through the [PSRAM](https://www.pjrc.com/store/psram.html) on the
Teensy. It is based on the LoTech [`LTEMM.EXE`](https://www.lo-tech.co.uk/wiki/LTEMM.EXE) driver and inspired by work by
Alex Tsourikov and Michael Karcher. Note that while the driver is compliant with EMS 4.0, it does not support memory
back-filling.

The device driver can be found here: [`XTEMM.EXE`](https://raw.githubusercontent.com/MicroCoreLabs/Projects/master/XTMax/Drivers/XTEMM.EXE).
Once downloaded, it must be placed on a drive accessible during boot and must be invoked from `CONFIG.SYS` as shown in
the example below:

```
DEVICE=A:\XTEMM.EXE /N
```

The address of the memory window used by the EMS driver is 0xD0000-0xDFFFF by default and can be changed with the `/P`
argument. For example, to use segment 0xE000 (mapping to 0xE0000-0xEFFFF), the syntax is as follows:

```
DEVICE=A:\XTEMM.EXE /P:E000 /N
```

## UMB Driver for MS-DOS (XTUMBS)

This driver provides Upper Memory Blocks (UMBs) in unused regions of the Upper Memory Area (UMA). It is based on the
`USE!UMBS` driver originally written by Marco van Zwetselaar and later rewritten by Krister Nordvall and published on
the [VCFED forum](https://forum.vcfed.org/index.php?threads/loading-dos-high-on-a-xt.32320/).

The device driver can be found here: [`XTUMBS.SYS`](https://raw.githubusercontent.com/MicroCoreLabs/Projects/master/XTMax/Drivers/XTUMBS.SYS).
Once downloaded, it must be placed on a drive accessible during boot and must be invoked from `CONFIG.SYS` as shown in
the example below:

```
DEVICE=A:\XTUMBS.SYS D000-E000
```

In the example above, the memory region at 0xD0000-0xDFFFF will be used as an UMB. **Care must be taken to not conflict
with other memory regions used by periperals or other drivers.** For example, the region at 0xD0000 may also be used
by the EMS driver, and both drivers shall not be configured to conflict with each other.

The XTMax can create UMBs at any address within the 0xA0000-0xEFFFF range. The only restriction is that the address and
size of the UMB must be a multiple of 2048 bytes (2KB).

The `XTUMBS` driver can accept several ranges for UMBs, as shown in the example below with two distinct ranges:

```
DEVICE=A:\XTUMBS.SYS A000-B000 D000-E000
```

**Note that the XTMax only enables RAM for the UMBs upon loading the `XTUMBS` driver. Therefore, tools such as
[`TEST!UMB.EXE](https://raw.githubusercontent.com/MicroCoreLabs/Projects/master/XTMax/Drivers/TEST!UMB.EXE) cannot be used to
identify available UMBs.** Instead, the user must identify the unavailable ranges (such as video RAM or ROMs) with tools
like CheckIt! and determine which ranges are safe to use as UMBs.
