; 读取分析数据，并将真实速度和垂直速度存储在新文件中
; 文件的格式参考adac_1.6.2.pdf


;---------------- 读文件 ---------------------
filehead = CREATE_STRUCT($
  'MagicNumber', 0L, $
  'Numbers', 0L, $
  'StartTime', 0L, $
  'EndTime', 0L $
  )

record_head = CREATE_STRUCT(NAME = 'RecordHead', $
  'MagicNumber', 0L, $
  'length', 0L, $
  'RecordTime', 0L, $
  'offset', 0L $
  )


record_parameter = CREATE_STRUCT(NAME = 'parameter', $
  record_head, $
  'Number_Of_Receiving_Channels', 0L, $
  'Active_Receiving_Channels1', 0L, $
  'Active_Receiving_Channels2', 0L, $
  'Active_Receiving_Channels3', 0L, $
  'Active_Receiving_Channels4', 0L, $
  'FCA_Receiving_channels1', 0L, $
  'FCA_Receiving_channels2', 0L, $
  'FCA_Receiving_channels3', 0L, $
  'Lowest_Range', 0L, $
  'RangeInterval', 0L, $
  'Range_extent', 0L, $
  'Radar_frequency', 0.0 $
  )

record = CREATE_STRUCT(NAME = 'Record', $
  'ErrorCode', 0L, $
  'v_a_zonal', 0.0, $
  'v_a_meridional', 0.0, $
  'v_t_zonal', 0.0, $
  'v_t_meridional', 0.0, $
  'v_ver', 0.0, $
  'corr_v_ver', 0.0, $
  'MAOA1', 0.0, 'MAOA2', 0.0, $
  'FadingTime', 0.0, $
  'PatternLifetime', 0.0, $
  'PatternScale', 0.0, $
  'AxialRatio', 0.0, $
  'AxialRotation', 0.0, $
  'PTD', 0L, $
  'SNR1', 0.0, 'SNR2', 0.0, 'SNR3', 0.0, 'SNR4', 0.0, $
  'AMP1', 0.0, 'AMP2', 0.0, 'AMP3', 0.0, 'AMP4', 0.0 $
  )

record_analysed = CREATE_STRUCT($
  NAME = 'Analysed', $
  ['head', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10', $
  'R11', 'R12', 'R13', 'R14', 'R15', 'R16', 'R17', 'R18', 'R19', 'R20', $
  'R21', 'R22', 'R23', 'R24', 'R25', 'R26'], $
  record_head, record, record, record, record, record, record, record, record, record, record, $ ; 10*record
  record, record, record, record, record, record, record, record, record, record, $ ; 10*record
  record, record, record, record, record, record $ ; 6*record
  )

data = CREATE_STRUCT(NAME = 'data', $
  ['parameter', 'analysed'], $
  record_parameter, record_analysed $
  )

datas = replicate(data, 480)  ; 不同的时间点,具体见

file = 'data/20140408_fca.fca'
OPENR, unit, file, /GET_LUN ,/SWAP_ENDIAN   ; /SWAP_ENDIAN 表示高地位的错开
READU, unit, filehead, datas
FREE_LUN, unit


;;---------------- 取读出文件中所需的速度 ---------------------
;
;; 定义存放v_t_zonal, v_t_meridional, v_ver的变量 具体结构见相应viso图
;;
;c =  FLTARR(3, 26*480) ; 最小单元存放一个range上的v_t_zonal, v_t_meridional, v_ver
;
;; 读取及存放
;FOR k = 0, 479 DO BEGIN
;  FOR i = 0, 25 DO BEGIN
;    c[0, 26*k + i] = datas(k).analysed.(i + 1).v_t_zonal
;    c[1, 26*k + i] = datas(k).analysed.(i + 1).v_t_meridional
;    c[2, 26*k + i] = datas(k).analysed.(i + 1).v_ver
;  ENDFOR
;ENDFOR
;
;x = REFORM(c[0, *]) ; zonal
;y = REFORM(c[1, *]) ; meridional
;z = REFORM(c[2, *]) ; corrected vertical
;
;;---------------- 画风羽图 ---------------------
;; 生成风的每个坐标(pox, poy)
;pox = INTARR(26*480)
;poy = pox
;FOR i = 0, 479 DO BEGIN
;  pox[[0:25] + 26*i] = REPLICATE(i+1, 26)
;  poy[[0:25] + 26*i] = INDGEN(26) + 1
;ENDFOR
;
;m = 479 ; 0-479 选择一个段来显示
;!p.font = 0 ; 支持中文标题
;g = vector(x[0:(25 + 26*m)], y[0:(25 + 26*m)], pox[0:(25 + 26*m)], poy[0:(25 + 26*m)], $
;  vector_style = 1, $
;  RGB_TABLE = 10, $
;  VECTOR_COLORS = z[0:(25 + 26*m)], $  ; 垂直风速用颜色显示
;  XTITLE = '当地时间', $
;  YTITLE = '高度/km', $
;  TITLE = '日期：2014年03月25日', $
;  font_name = '黑体', font_size = 12, $
;  XTICKNAME = ['8时01分', '10时22分', '12时46分', '15时10分', '17时34分', '19时58分', '22时22分', '0时46分', '3时10分', '5时34分', '7时58分'], $
;  YTICKNAME = ['50', '60', '70', '80', '90', '100', '110'] $
;  )
;c = COLORBAR(TARGET = im, $
;  ;               POSITION=[-1,-0.1,0.29,0.9], $
;  ORIENTATION = 0, $
;  font_name = '黑体', font_size = 12, $
;  TITLE='垂直速度(m/s)' $
;  )
end








; help, datas(49).ANALYSED.(18), /struct
; 没有通道低于-6dB，但是错误代码显示为2