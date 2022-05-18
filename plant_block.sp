#include <sourcemod>
#include <sdktools>
#include <csgo_colors>
#include <multicolors>

#pragma tabsize 0

#define MINPLAYERS 10
int current_plant;

char plant[2][] = {"A","B"};
char Tag[5][] = 
{	
	"[==____________] ",
	"[====_________] ",
	"[======______] ",
	"[========___] ",
	"[==========] "
}
int randomText;

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
	LoadTranslations("plant_blocker_random.phrases.txt");
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
				char buffer[256];
				Format(buffer,sizeof(buffer),"%t","searching")
				SetHudTextParams(0.45, 1.0, 1.0, 0 , 255, 0, 0, 2, 0.0 , 0.0, 0.0);
				ShowHudText(i, -1, buffer);
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
		Format(buffer, sizeof(buffer), "%t","TimerCountDown",Tag[i],InformationText[i])
	}
	else if (randomText == 1)
	{
		Format(buffer, sizeof(buffer), "%t","TimerCountDown",Tag[i],InformationText2[i])
	}
	else if (randomText == 2)
	{
		Format(buffer, sizeof(buffer), "%t","TimerCountDown",Tag[i],InformationText3[i])
	}
	for (int j = 0;j<MaxClients;j++)
	{
		if(!IsFakeClient(iClient) && IsClientInGame(iClient))
		{
			if(IsPlayerAlive(iClient)) 
			{
				switch(GetEngineVersion())
				{
					case Engine_CSGO: CGOPrintToChat(iClient, buffer);
					case Engine_CSS: CPrintToChat(iClient, buffer);
					default: PrintToChat(iClient, buffer);
				}
			}
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
		Format(buffer, sizeof(buffer), "%t","plant_announce",plant[1],plant[0]);
		current_plant = 1;
	}
	
	else 
	{
		Format(buffer, sizeof(buffer), "%t","plant_announce",plant[0],plant[1]);
		current_plant = 2;
	}
	
	for (int j = 0;j<MaxClients;j++)
	{
		if(!IsFakeClient(iClient) && IsClientInGame(iClient))
		{
			if(IsPlayerAlive(iClient))
			{
				switch(GetEngineVersion())
				{
					case Engine_CSGO: CGOPrintToChat(iClient, buffer);
					case Engine_CSS: CPrintToChat(iClient, buffer);
					default: PrintToChat(iClient, buffer);
				}
			}
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
				char buffer[256];
				Format(buffer,sizeof(buffer),"%t","searching");
				SetHudTextParams(0.45, 1.0, 1.0, 0 , 255, 0, 0, 2, 0.0 , 0.0, 0.0);
				if(current_plant == 2) 
				{
					Format(buffer,sizeof(buffer),"%t","the_plant",plant[1]);
					ShowHudText(i, -1, buffer);
				}
				else if(current_plant == 1) 
				{
					Format(buffer,sizeof(buffer),"%t","the_plant",plant[0]);
					ShowHudText(i, -1, buffer);
				}
				else 
				{
					ShowHudText(i, -1, buffer);
				}
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
				char buffer2[256];
				if(BLOCKPLANT == 1) Format(buffer2,sizeof(buffer2),"%t","blocked",plant[0]);
				else Format(buffer2,sizeof(buffer2),"%t","blocked",plant[1]);
				switch(GetEngineVersion())
				{
					case Engine_CSGO: CGOPrintToChat(iClient, buffer2);
					case Engine_CSS: CPrintToChat(iClient, buffer2);
					default: PrintToChat(iClient, buffer2);
				}
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
