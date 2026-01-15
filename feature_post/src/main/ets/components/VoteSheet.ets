import { PostPageVM } from '../viewmodels/PostPageVM';

@Builder
export function voteSheetBuilder(vm: PostPageVM) {
  VoteSheet({ vm })
}

@ComponentV2
struct VoteSheet {
  @Param @Require vm: PostPageVM;

  build() {
    Text("test")
  }
}