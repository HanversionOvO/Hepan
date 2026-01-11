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

export enum WaterMissionState {
  NEW = "new", // 新任务
  DOING = "doing", // 进行中
  FINISH = "done", // 完成
  FAIL = "failed" // 失败
}

@ObservedV2
export class WaterMission {
  @Trace mission_icon: string = ""; // 任务图标
  @Trace mission_name: string = ""; // 任务名称
  @Trace mission_state: WaterMissionState = WaterMissionState.NEW;
  @Trace mission_hot: number = 0; // 任务人气
  @Trace mission_href?: string; // 任务接收/放弃链接 (只有进行中/新任务的任务有)
  @Trace mission_desc?: string; // 任务描述
  @Trace mission_reward: string = "" // 任务奖励类型
  @Trace mission_reward_value: string = "" // 奖励值
  @Trace mission_progress?: number; // 任务进度 (只有进行中的任务有)
}

@ObservedV2
export class WaterShopItem {
  @Trace shop_mid: string = ""; // 道具ID
  @Trace shop_icon: string = ""; // 道具图标
  @Trace shop_name: string = ""; // 道具名称
  @Trace can_buy: boolean = true; // 是否可购买
  @Trace shop_price: number = 0; // 道具价格
}

@ObservedV2
export class WaterBackpackItem {
  @Trace backpack_icon: string = ""; // 道具图标
  @Trace backpack_name: string = ""; // 道具名称
  @Trace backpack_nums: number = 0; // 道具数量
}