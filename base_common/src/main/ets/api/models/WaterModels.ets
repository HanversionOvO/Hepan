@ObservedV2
export class WaterRecord {
  @Trace modify_desc: string = ""; // 操作描述
  @Trace modify_state: number = 0; // 操作状态 (0: 增加 | 1: 减少)
  @Trace modify_water: number = 0; // 水滴操作数量
  @Trace modyfy_info: string = ""; // 操作详情
  @Trace modify_time: string = ""; // 操作时间
}

@ObservedV2
export class WaterModels {
  @Trace water_nums: number = 0; // 水滴数量
  @Trace records: WaterRecord[] = []; // 水滴操作记录
}