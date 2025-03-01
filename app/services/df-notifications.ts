import Service, { service } from '@ember/service';
import NotificationsService from 'ember-cli-notifications/services/notifications';

export default class DFNotificationsService extends Service {
  @service declare notifications: NotificationsService;

  notifyError(msg: string) {
    // NOTE: acceptance test `repositories: failed response` fails with `autoClear=true`
    this.notifications?.error(msg, {
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
