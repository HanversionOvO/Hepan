@ObservedV2
export class AuthModel {
  @Trace authorization: string = '';
  @Trace cookie: string = '';
  @Trace uid: number = 0;
  @Trace username: string = '';

  get isLoggedIn(): boolean {
    return !!this.authorization && !!this.cookie;
  }

  reset(): void {
    this.authorization = '';
    this.cookie = '';
    this.uid = 0;
    this.username = '';
  }
}