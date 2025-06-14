<script lang="ts">
	import { cn } from '$lib/utils/style';
	import type { HTMLImgAttributes } from 'svelte/elements';

	let props: HTMLImgAttributes & {} = $props();
</script>

<div class={'bg-muted flex items-center justify-center rounded-2xl p-3'}>
	<img class={cn('size-24 object-contain', props.class)} {...props} />
</div>
