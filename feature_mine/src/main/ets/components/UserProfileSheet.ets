import { MinePageVM } from "../viewmodels/MinePageVM";

@Builder
export function userProfileSheetBuilder(vm: MinePageVM) {
  UserProfileSheet({vm});
}

@ComponentV2
struct UserProfileSheet {
  @Param @Require vm: MinePageVM;
  
  build() {
    
  }
}