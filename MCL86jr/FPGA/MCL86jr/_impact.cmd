setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
loadProjectFile -file "C:\MCL\MCL86\MCL86jr\MCL86jr_Impact.ipf"
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setCurrentDesign -version 0
setMode -pff
setCurrentDeviceChain -index 0
setMode -bs
setMode -bs
setMode -bs
setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
assignFile -p 1 -file "C:/MCL/MCL86/MCL86jr/MCL86jr/mcl86jr.bit"
Program -p 1 
attachflash -position 1 -spi "W25Q128FV"
assignfiletoattachedflash -position 1 -file "C:/MCL/MCL86/MCL86jr/Untitled.mcs"
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
loadProjectFile -file "C:\MCL\MCL86\MCL86jr\MCL86jr_Impact.ipf"
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setMode -pff
setCurrentDesign -version 0
setMode -pff
setCurrentDeviceChain -index 0
setSubmode -pffspi
setMode -pff
setMode -bs
setMode -pff
setSubmode -pffspi
setSubmode -pffspi
setMode -bs
setMode -bs
setMode -bs
setMode -pff
setSubmode -pffspi
setSubmode -pffspi
setMode -pff
setSubmode -pffspi
generate
setCurrentDesign -version 0
setMode -bs
setMode -bs
setMode -bs
setMode -pff
setSubmode -pffspi
setSubmode -pffspi
setMode -bs
setMode -bs
setMode -bs
setMode -pff
setSubmode -pffspi
setSubmode -pffspi
setMode -bs
setMode -bs
setMode -bs
setCable -port auto
Identify -inferir 
identifyMPM 
attachflash -position 1 -spi "W25Q128FV"
assignfiletoattachedflash -position 1 -file "C:/MCL/MCL86/MCL86jr/Untitled.mcs"
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
saveProjectFile -file "C:\MCL\MCL86\MCL86jr\MCL86jr_Impact.ipf"
Program -p 1 -dataWidth 1 -spionly -e -v -loadfpga 
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
saveProjectFile -file "C:\MCL\MCL86\MCL86jr\MCL86jr_Impact.ipf"
setMode -bs
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
saveProjectFile -file "C:\MCL\MCL86\MCL86jr\MCL86jr_Impact.ipf"
setMode -bs
setMode -pff
setMode -bs
deleteDevice -position 1
setMode -bs
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
deletePromDevice -position 1
setCurrentDesign -version 0
deleteDevice -position 1
deleteDesign -version 0
setCurrentDesign -version -1
