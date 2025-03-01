import { modifier } from 'ember-modifier';

interface ResetFiltersSignature {
  Element: HTMLElement;
  Args: {
    Named: {};
    Positional: [() => void];
  };
}

export default modifier<ResetFiltersSignature>(function resetFilters(
  element,
  [resetAction],
) {
  resetAction();
});
