{{--The @props line code below allows you to make your employer logo dynamic --}}
@props(['width' => 90])

<img src="https://picsum.photos/seed/{{rand(0, 100000)}}/{{ $width }}" alt="" class="rounded-xl"/>
