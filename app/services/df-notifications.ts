import Service, { service } from '@ember/service';

export interface EmberNotificationsService {
  error(message: string, options?: object): void;
}

export default class DFNotificationsService extends Service {
  @service declare notifications: EmberNotificationsService;

  notifyError(msg: string) {
    // NOTE: acceptance test `repositories: failed response` fails with `autoClear=true`
    this.notifications.error(msg, {
      // autoClear: true,
      // clearDuration: 2000,
    });
  }
}

declare module '@ember/service' {
  interface Registry {
    'df-notifications': DFNotificationsService;
  }
}
