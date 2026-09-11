import { ChangeDetectionStrategy, Component, computed, effect, inject, inputBinding, runInInjectionContext, signal, Signal, ViewContainerRef } from '@angular/core';
import { ForgeButtonModule, ForgeCardModule, ForgeExpansionPanelModule, ForgeIconModule, ForgeOpenIconModule, ForgeScaffoldModule, ForgeTableModule, ForgeToolbarModule, ToastService } from '@tylertech/forge-angular';
import { CaseCalculatedFeeStore } from '../../../stores/case-calculated-fee.store';
import { ICaseCalculatedFee } from '../../../data-types/cases/ICaseCalculatedFee';
import { ICaseCalculatedFeeTableRow } from '../../../data-types/cases/ICaseCalculatedFeeTableRow';
import { IColumnConfiguration, IconButtonComponent, IconComponent, IconRegistry, TooltipComponent } from '@tylertech/forge';
import { CommonDynamicLabelValueComponent, FormInputTypeEnum, FormValueDensityEnum, FormValueOperationEnum, FormValueTypeEnum } from '../../../core/components/common-dynamic-label-value/common-dynamic-label-value.component';
import { FeesPaidByOptionsConstant } from '../../../types/constants/FeesPaidByOptionsConstant';
import { tylIconCheck, tylIconClose, tylIconRefresh } from '@tylertech/tyler-icons';
import { tap } from 'rxjs';

@Component({
  selector: 'tyl-case-details-dr513-fees',
  templateUrl: './case-details-dr513-fees.component.html',
  styleUrl: './case-details-dr513-fees.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    ForgeButtonModule,
    ForgeCardModule,
    ForgeExpansionPanelModule,
    ForgeOpenIconModule,
    ForgeTableModule,
    ForgeToolbarModule,
    ForgeIconModule,
    ForgeScaffoldModule,
    CommonDynamicLabelValueComponent,
  ],
})
export class CaseDetailsDr513FeesComponent {
  private readonly _viewContainerRef: ViewContainerRef = inject(ViewContainerRef);

  private readonly _toastService: ToastService = inject(ToastService);

  private readonly _caseCalculatedFeeStore: CaseCalculatedFeeStore = inject(CaseCalculatedFeeStore);

  protected readonly _caseCalculatedFees: Signal<ICaseCalculatedFee[]> = this._caseCalculatedFeeStore.data;

  protected readonly _data: Signal<ICaseCalculatedFeeTableRow[]> = computed(() => {
    return this._caseCalculatedFees().map(
      fee =>
        ({
          fee: fee,
          baseFee: fee.countyStandardFee ?? fee.countyCustomFee ?? undefined,
          billToApplicant: false,
          invoiceNumber: '',
          operationMode: signal<FormValueOperationEnum>(FormValueOperationEnum.View),
          currentValue: signal(fee.value),
        }) as ICaseCalculatedFeeTableRow,
    );
  });

  protected readonly _fetching: Signal<boolean> = this._caseCalculatedFeeStore.fetching;

  protected readonly _saving: Signal<boolean> = this._caseCalculatedFeeStore.saving;

  protected readonly _editing: Signal<boolean> = computed(() => {
    return this._data().some(row => row.operationMode() === FormValueOperationEnum.Edit);
  });

  protected readonly _totalValue: Signal<number> = computed(() => {
    return this._data().reduce((acc, row) => acc + row.fee.value, 0);
  });

  protected readonly _columnConfiguration: IColumnConfiguration[] = [
    {
      header: 'Fee type',
      cellStyle: { minWidth: '24rem', maxWidth: '24rem', width: '24rem' },
      template: (_i, _d, rowData: ICaseCalculatedFeeTableRow) => {
        const span = document.createElement('span');
        span.innerText = rowData.fee.countyStandardFee?.standardFee?.name ?? rowData.fee.countyCustomFee?.name ?? 'UNKNOWN';
        return span;
      }
    },
    {
      header: 'Fee',
      cellStyle: { minWidth: '12rem', maxWidth: '12rem', width: '12rem', textAlign: 'right', paddingRight: '1rem' },
      template: (_i, div: HTMLElement, rowData: ICaseCalculatedFeeTableRow) => {
        const component = this._viewContainerRef.createComponent(CommonDynamicLabelValueComponent, {
          bindings: [
            inputBinding('density', signal(FormValueDensityEnum.Small)),
            inputBinding('code', signal(true)),
            inputBinding('loading', this._saving),
            inputBinding('valueType', signal(FormValueTypeEnum.Text)),
            inputBinding('inputType', signal(FormInputTypeEnum.Currency)),
            inputBinding('decimalPlaces', signal(2)),
            inputBinding('valueMode', rowData.operationMode.asReadonly()),
            inputBinding('value', rowData.currentValue),
          ],
        });
        const componentElement = component.location.nativeElement;

        component.instance.registerOnChange(x => rowData.currentValue.set(Number(x)));
        if (rowData.fee.overridden || rowData.currentValue() !== rowData.fee.value) {
          componentElement.style.fontWeight = 900;
          componentElement.style.fontStyle = 'italic';

          const tooltip = new TooltipComponent();
          tooltip.innerText = 'This fee has been overridden and can not be recalculated.';
          tooltip.placement = 'bottom';
          tooltip.style.fontStyle = 'unset';
          componentElement.appendChild(tooltip);
        }
        div.appendChild(componentElement);

        return undefined;
      },
    },
    {
      header: 'Bill to applicant?',
      cellStyle: { minWidth: '4rem', maxWidth: '4rem', width: '4rem' },
      template: (_i, _d, rowData: ICaseCalculatedFeeTableRow) => {
        return this._viewContainerRef.createComponent(CommonDynamicLabelValueComponent, {
          bindings: [
            inputBinding('density', signal(FormValueDensityEnum.Small)),
            inputBinding('valueType', signal(FormValueTypeEnum.Checkbox)),
            inputBinding('inputType', signal(FormInputTypeEnum.Boolean)),
            inputBinding('valueMode', rowData.operationMode.asReadonly()),
            inputBinding('value', signal(rowData.billToApplicant)),
            inputBinding('disabled', signal(true))
          ],
        }).location.nativeElement;
      },
    },
    {
      header: 'Invoice #',
      cellStyle: { minWidth: '10rem', maxWidth: '10rem', width: '10rem' },
      template: (_i, _d, rowData: ICaseCalculatedFeeTableRow) => {
        return this._viewContainerRef.createComponent(CommonDynamicLabelValueComponent, {
          bindings: [
            inputBinding('density', signal(FormValueDensityEnum.Small)),
            inputBinding('showEmpty', signal(true)),
            inputBinding('valueType', signal(FormValueTypeEnum.Text)),
            inputBinding('inputType', signal(FormInputTypeEnum.Number)),
            inputBinding('valueMode', rowData.operationMode.asReadonly()),
            inputBinding('value', signal(rowData.invoiceNumber)),
            inputBinding('disabled', signal(true))
          ],
        }).location.nativeElement;
      },
    },
    {
      header: 'Redemption?',
      cellStyle: { minWidth: '4rem', maxWidth: '4rem', width: '4rem' },
      template: (_i, _d, rowData: ICaseCalculatedFeeTableRow) => {
        return this._viewContainerRef.createComponent(CommonDynamicLabelValueComponent, {
          bindings: [
            inputBinding('density', signal(FormValueDensityEnum.Small)),
            inputBinding('valueType', signal(FormValueTypeEnum.Checkbox)),
            inputBinding('inputType', signal(FormInputTypeEnum.Boolean)),
            inputBinding('valueMode', rowData.operationMode.asReadonly()),
            inputBinding('value', signal(rowData.baseFee?.redemptionAmount ?? false)),
            inputBinding('disabled', signal(true))
          ],
        }).location.nativeElement;
      },
    },
    {
      header: 'Opening bid?',
      cellStyle: { minWidth: '4rem', maxWidth: '4rem', width: '4rem' },
      template: (_i, _d, rowData: ICaseCalculatedFeeTableRow) => {
        return this._viewContainerRef.createComponent(CommonDynamicLabelValueComponent, {
          bindings: [
            inputBinding('density', signal(FormValueDensityEnum.Small)),
            inputBinding('code', signal(true)),
            inputBinding('valueType', signal(FormValueTypeEnum.Checkbox)),
            inputBinding('inputType', signal(FormInputTypeEnum.Boolean)),
            inputBinding('valueMode', rowData.operationMode.asReadonly()),
            inputBinding('value', signal(rowData.baseFee?.openingBid ?? false)),
            inputBinding('disabled', signal(true))
          ],
        }).location.nativeElement;
      },
    },
    {
      header: 'Paid to',
      cellStyle: { minWidth: '16rem' },
      template: (_i, _d, rowData: ICaseCalculatedFeeTableRow) => {
        return this._viewContainerRef.createComponent(CommonDynamicLabelValueComponent, {
          bindings: [
            inputBinding('density', signal(FormValueDensityEnum.Small)),
            inputBinding('valueType', signal(FormValueTypeEnum.Select)),
            inputBinding('inputType', signal(FormInputTypeEnum.String)),
            inputBinding('valueMode', rowData.operationMode.asReadonly()),
            inputBinding('selectOptions', signal(FeesPaidByOptionsConstant)),
            inputBinding('value', signal(rowData.baseFee?.paidByOptionsId ?? 0)),
            inputBinding('disabled', signal(true))
          ],
        }).location.nativeElement;
      },
    },
    {
      header: 'Actions',
      width: 0,
      template: (_i, div: HTMLElement, rowData: ICaseCalculatedFeeTableRow) => {
        const editButton = new IconButtonComponent();
        const cancelButton = new IconButtonComponent();
        const saveButton = new IconButtonComponent();
        const editIcon = new IconComponent();
        const cancelIcon = new IconComponent();
        const saveIcon = new IconComponent();

        editButton.appendChild(editIcon);
        cancelButton.appendChild(cancelIcon);
        saveButton.appendChild(saveIcon);

        editButton.addEventListener('click', () => this._handleEditClick(rowData));
        cancelButton.addEventListener('click', () => this._handleCancelEditClick(rowData));
        saveButton.addEventListener('click', () => this._handleSaveEditClick(rowData));

        editIcon.name = 'edit';
        cancelIcon.name = 'close';
        saveIcon.name = 'check';
        
        div.style.display = 'flex';
        div.style.gap = '0.5rem';
        div.style.justifyContent = 'flex-end';

        div.appendChild(editButton);
        div.appendChild(cancelButton);
        div.appendChild(saveButton);

        runInInjectionContext(this._viewContainerRef.injector, () => {
          effect(() => {
            const isEditing = rowData.operationMode() === FormValueOperationEnum.Edit;
            editButton.style.display = isEditing ? 'none' : 'inline-flex';
            cancelButton.style.display = isEditing ? 'inline-flex' : 'none';
            saveButton.style.display = isEditing ? 'inline-flex' : 'none';
          });
        });

        return undefined;
      }
    }
  ];

  public readonly FormInputTypeEnum = FormInputTypeEnum;

  public readonly FormValueOperationEnum = FormValueOperationEnum;

  protected _handleEditClick(selectedFee: ICaseCalculatedFeeTableRow): void {
    selectedFee.operationMode.set(FormValueOperationEnum.Edit);
  }

  protected _handleCancelEditClick(selectedFee: ICaseCalculatedFeeTableRow): void {
    selectedFee.operationMode.set(FormValueOperationEnum.View);
    selectedFee.currentValue.set(selectedFee.fee.value);
    this._toastService.show({
      message: 'Edit canceled.',
      theme: 'info',
      dismissible: true,
    });
  }

  protected _handleSaveEditClick(selectedFee: ICaseCalculatedFeeTableRow): void {
    console.log(selectedFee);
    const updatedFee = {
      ...selectedFee.fee,
      value: selectedFee.currentValue(),
      overridden: selectedFee.fee.overridden || selectedFee.currentValue() !== selectedFee.fee.value
    } as ICaseCalculatedFee;

    this._caseCalculatedFeeStore.save(updatedFee).pipe(
      tap(() => selectedFee.operationMode.set(FormValueOperationEnum.View))
    ).subscribe();
  }

  protected _handleRecalculateClick(): void {
    this._caseCalculatedFeeStore.recalculateFees();
  }

  static {
    IconRegistry.define([
      tylIconRefresh,
      tylIconCheck,
      tylIconClose
    ]);
  }
}
