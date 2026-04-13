<!-- @if ($paginator->hasPages())
    <ul class="pagination">
        {{-- Tombol Previous --}}
        @if ($paginator->onFirstPage())
            <li class="disabled"><span>&laquo; Previous</span></li>
        @else
            <li><a href="{{ $paginator->previousPageUrl() }}" rel="prev">&laquo; Previous</a></li>
        @endif

        {{-- Angka Halaman --}}
        @foreach ($elements as $element)
            {{-- Separator ("...") --}}
            @if (is_string($element))
                <li class="disabled"><span>{{ $element }}</span></li>
            @endif

            {{-- Link Halaman --}}
            @if (is_array($element))
                @foreach ($element as $page => $url)
                    @if ($page == $paginator->currentPage())
                        <li class="active"><span>{{ $page }}</span></li>
                    @else
                        <li><a href="{{ $url }}">{{ $page }}</a></li>
                    @endif
                @endforeach
            @endif
        @endforeach

        {{-- Tombol Next --}}
        @if ($paginator->hasMorePages())
            <li><a href="{{ $paginator->nextPageUrl() }}" rel="next">Next &raquo;</a></li>
        @else
            <li class="disabled"><span>Next &raquo;</span></li>
        @endif
    </ul>
@endif -->
