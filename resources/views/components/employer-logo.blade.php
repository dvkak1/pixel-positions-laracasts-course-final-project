{{--The @props line code below allows you to make your employer logo dynamic --}}
@props(['employer', 'width' => 90])

<img src="{{ asset($employer->logo) }}" alt="" class="rounded-xl" width="{{ $width }}"/>
