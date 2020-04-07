declare module 'accent-webapp/utils/phoenix' {
  type Ref = number;
  type Status = string;
  type Event = string;
  type Topic = string;

  class Push {
    constructor(
      channel: Channel,
      event: Event,
      payload: object,
      timeout: number
    );

    receive(status: Status, callback: any): Push;
  }

  class Channel {
    constructor(topic: Topic, params: object, socket: Socket);

    join(timeout?: number): Push;
    leave(timeout?: number): Push;
    on(event: Event, callback: (payload: any) => any): Ref;
    off(event: Event, ref: Ref): void;
  }

  class Socket {
    constructor(endPoint: string, opts?: object);

    disconnect(
      callback: () => any,
      code: number,
      reason: string
    ): undefined | any;
    connect(params?: object): void;
    channel(topic: Topic, chanParams?: object): Channel;
  }
}
