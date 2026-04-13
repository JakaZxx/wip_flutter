<?php

namespace App\Exports;

use App\Models\Commodity;
use App\Models\Borrowing;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;

class AssetsExport implements FromCollection, WithHeadings
{
    protected $assets;
    protected $borrowings;

    public function __construct($assets, $borrowings)
    {
        $this->assets = $assets;
        $this->borrowings = $borrowings;
    }

    public function collection()
    {
        $data = [];

        foreach ($this->borrowings as $borrowing) {
            foreach ($borrowing->commodities as $commodity) {
                $data[] = [
                    'Asset Name' => $commodity->name ?? 'N/A',
                    'Quantity' => $commodity->pivot->quantity,
                    'Status' => $borrowing->status,
                    'Borrow Date' => $borrowing->borrow_date,
                    'Return Date' => $borrowing->return_date,
                ];
            }
        }

        return collect($data);
    }

    public function headings(): array
    {
        return [
            'Asset Name',
            'Quantity',
            'Status',
            'Borrow Date',
            'Return Date',
        ];
    }
}
