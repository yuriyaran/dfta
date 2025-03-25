import { helper } from '@ember/component/helper';

export default helper(function pluralize([number, word]: [
  number,
  string,
]): string {
  const isSingle = number.toString().endsWith('1');

  return isSingle ? word : word + 'es';
});
