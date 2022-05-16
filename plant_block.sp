#include <sourcemod>
#include <sdktools>
#include <csgo_colors>

#pragma tabsize 0

#define MINPLAYERS 10
int current_plant;

char plant[2][] = {"A","B"};
char Tag[5][] = 
{	
	"{DEFAULT}[{RED}=={DEFAULT}____________] ",
	"{DEFAULT}[{RED}===={DEFAULT}_________] ",
	"{DEFAULT}[{RED}======{DEFAULT}______] ",
	"{DEFAULT}[{RED}========{DEFAULT}___] ",
	"{DEFAULT}[{RED}=========={DEFAULT}] "
}
int randomText;
/* char TagColor[13][] = 
{
	"{DEFAULT}",
	"{RED}","{LIGHTPURPLE}","{GREEN}",
	"{LIME}","{LIGHTGREEN}","{LIGHTRED}",
	"{GRAY}","{LIGHTOLIVE}","{OLIVE}",
	"{PURPLE}","{LIGHTBLUE}","{BLUE}"
} */

char InformationText[][] = 
{
	"Триангулируем местность...", "Ищем место закладки...", "Расчитываем траекторию...", "Подбираем пароль...","Успех!!!"
}

char InformationText2[][] = 
{
	"Ищем место закладки...", "Триангулируем местность...", "Подбираем пароль...", "Расчитываем траекторию..." ,"Успех!!!"
}

char InformationText3[][] = 
{
	"Расчитываем траекторию...",  "Подбираем пароль...", "Триангулируем местность...", "Ищем место закладки...", "Успех!!!"
}

int BLOCKPLANT;

public void OnPluginStart()
{
	HookEvent("round_start", EventRoundStart);
}

public void EventRoundStart(Event hEvent, const char[] sEvName, bool bDontBroadcast)
{
	randomText = GetRandomInt(0,2)
	int ConValue;
	float ConValueInt;
	ConValue = GetConVarInt(FindConVar("mp_freezetime"));
	ConValueInt = float(ConValue)
	current_plant = 0;
	CreateTimer(1.0,OnHudUpdate,_,TIMER_REPEAT);
	CreateTimer(ConValueInt, TimerCallback);
	for (int i = 0;i<ConValueInt;i++)
	{
		float Num = float(i);
		CreateTimer(Num,TimerCountDown, i);
	}
	BLOCKPLANT = GetRandomInt(1,2);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			if(IsPlayerAlive(i))
			{
				SetHudTextParams(0.45, 1.0, 1.0, 0 , 255, 0, 0, 2, 0.0 , 0.0, 0.0);
				ShowHudText(i, -1, "SEARCHING THE PLANT...");
			}
		}	
	}
}

public Action TimerCountDown(Handle hTimer, i)
{
	int iClient;
	char buffer[256];
	if(randomText == 0)
	{
		Format(buffer, sizeof(buffer), "%s{OLIVE}%s",Tag[i],InformationText[i])
	}
	else if (randomText == 1)
	{
		Format(buffer, sizeof(buffer), "%s{OLIVE}%s",Tag[i],InformationText2[i])
	}
	else if (randomText == 2)
	{
		Format(buffer, sizeof(buffer), "%s{OLIVE}%s",Tag[i],InformationText3[i])
	}
	for (int j = 0;j<MaxClients;j++)
	{
		if(!IsFakeClient(iClient) && IsClientInGame(iClient))
		{
			if(IsPlayerAlive(iClient)) CGOPrintToChat(iClient,buffer);
		}	
	}
	
	KillTimer(hTimer);
}

public Action TimerCallback(Handle timer, Handle hndl)
{
	int iClient;
	char buffer[256];
	if(BLOCKPLANT == 1) 
	{
		Format(buffer, sizeof(buffer), "{PURPLE}➠{DEFAULT} Плент {RED}%s {DEFAULT}заблокирован! Доступный плент{GREEN} %s",plant[1],plant[0]);
		current_plant = 1;
	}
	
	else 
	{
		Format(buffer, sizeof(buffer), "{PURPLE}➠{DEFAULT} Плент {RED}%s {DEFAULT}заблокирован! Доступный плент{GREEN} %s",plant[0],plant[1]);
		current_plant = 2;
	}
	
	for (int j = 0;j<MaxClients;j++)
	{
		if(!IsFakeClient(iClient) && IsClientInGame(iClient))
		{
			if(IsPlayerAlive(iClient)) CGOPrintToChat(iClient,buffer);
		}	
	}
}

public Action OnHudUpdate(Handle hTimer)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			if(IsPlayerAlive(i))
			{
				SetHudTextParams(0.45, 1.0, 1.0, 0 , 255, 0, 0, 2, 0.0 , 0.0, 0.0);
				if(current_plant == 2) ShowHudText(i, -1, "PLANT %s",plant[1]);
				else if(current_plant == 1) ShowHudText(i, -1, "PLANT %s",plant[0]);
				else ShowHudText(i, -1, "SEARCHING THE PLANT...");
			}
		}
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int iClient, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{	
    if (buttons & IN_ATTACK || buttons & IN_USE)
    {
        if(GetOnlinePlayers() < MINPLAYERS)
        {      
            if (weapon != -1)
            {
                char buffer[64];
                GetClientWeapon(iClient, buffer, sizeof buffer);
                if (StrEqual(buffer, "weapon_c4"))
                {
                    if (GetEntProp(iClient, Prop_Send, "m_bInBombZone") == 1)
                    {
                        if(DistanceToPlants(iClient) == BLOCKPLANT)
                        {
							if(BLOCKPLANT == 1) CGOPrintToChat(iClient,"ПЛЕНТ ЗАБЛОКИРОВАН, ИДИ НА {GREEN}%s",plant[0]);
							else CGOPrintToChat(iClient,"ПЛЕНТ ЗАБЛОКИРОВАН, ИДИ НА {GREEN}%s",plant[1]);
                            if (buttons & IN_ATTACK && buttons & IN_USE)
                            {
                                buttons &= ~IN_ATTACK;
                                buttons &= ~IN_USE;                                
                            }
                            else if(buttons & IN_ATTACK)
                            {
                                buttons &= ~IN_ATTACK;
                            }
                            else if(buttons & IN_USE)
                            {
                                buttons &= ~IN_USE;
                            }                            
                            return Plugin_Changed;
                        }
                    }
                }
            }
        }
    }
    return Plugin_Continue;
} 

int DistanceToPlants(int iClient)
{
    if(iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient))
    {
        float vecBombsiteCenterA[3],
            vecBombsiteCenterB[3],
            vecClient[3];
        int index = -1;
        
        index = FindEntityByClassname(index, "cs_player_manager");
        if (index != -1)
        {
            GetEntPropVector(index, Prop_Send, "m_bombsiteCenterA", vecBombsiteCenterA);
            GetEntPropVector(index, Prop_Send, "m_bombsiteCenterB", vecBombsiteCenterB);
        }
        GetClientAbsOrigin(iClient, vecClient);

        if(GetVectorDistance(vecBombsiteCenterA, vecClient) >= GetVectorDistance(vecBombsiteCenterB, vecClient))
        {
            return 1; // B site
        }
		else
		{
            return 2; // A site
        }
    }
    return -1;
}

int GetOnlinePlayers( )
{
    int count = 0;
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && GetClientTeam(i) > 1)
        {
            ++count;
        }
    }
    return count;
}