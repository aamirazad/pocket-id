<script lang="ts">
import { startAuthentication } from "@simplewebauthn/browser";
import { fade } from "svelte/transition";
import { goto } from "$app/navigation";
import SignInWrapper from "$lib/components/login-wrapper.svelte";
import { Button } from "$lib/components/ui/button";
import { m } from "$lib/paraglide/messages";
import WebAuthnService from "$lib/services/webauthn-service";
import appConfigStore from "$lib/stores/application-configuration-store";
import userStore from "$lib/stores/user-store";
import { getWebauthnErrorMessage } from "$lib/utils/error-util";
import LoginLogoErrorSuccessIndicator from "./components/login-logo-error-success-indicator.svelte";

const { data } = $props();

const webauthnService = new WebAuthnService();

let isLoading = $state(false);
let error: string | undefined = $state(undefined);

async function authenticate() {
	error = undefined;
	isLoading = true;
	try {
		const loginOptions = await webauthnService.getLoginOptions();
		const authResponse = await startAuthentication({
			optionsJSON: loginOptions,
		});
		const user = await webauthnService.finishLogin(authResponse);

		await userStore.setUser(user);
		goto(data.redirect || "/settings");
	} catch (e) {
		error = getWebauthnErrorMessage(e);
	}
	isLoading = false;
}
</script>

<svelte:head>
	<title>{m.sign_in()}</title>
</svelte:head>

<SignInWrapper showAlternativeSignInMethodButton>
	<div class="flex justify-center">
		<LoginLogoErrorSuccessIndicator error={!!error} />
	</div>
	<h1 class="font-playfair mt-5 text-3xl font-bold sm:text-4xl">
		{m.sign_in_to_appname({ appName: $appConfigStore.appName })}
	</h1>
	{#if error}
		<p class="text-muted-foreground mt-2" in:fade>
			{error}. {m.please_try_to_sign_in_again()}
		</p>
	{:else}
		<p class="text-muted-foreground mt-2" in:fade>
			Authenticate yourself with your email or passkey to access your account.
		</p>
	{/if}
	<div class="mt-10 flex justify-center gap-3">
		{#if $appConfigStore.allowUserSignups === 'open'}
			<Button variant="secondary" href="/signup">
				{m.signup()}
			</Button>
		{/if}
		<Button onclick={() => {
			goto("/login/alternative/email")
		}}>
			"Login with Email"
		</Button>
		<Button {isLoading} onclick={authenticate} autofocus={true}>
			{error ? m.try_again() : "Login with Passkey"}
		</Button>
	</div>
</SignInWrapper>
